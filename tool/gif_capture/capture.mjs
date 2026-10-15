#!/usr/bin/env node
/**
 * Captura escenas de Flutter Web sin puntero y produce GIFs optimizados.
 * Las escenas animan sus propios controles; Playwright solo captura frames.
 * Uso interno: invocado por tool/generate_component_gifs.sh.
 */
import { chromium } from 'playwright';
import { spawnSync } from 'node:child_process';
import { mkdtemp, mkdir, rm } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const scenarios = ['buttons', 'dropdown', 'segmented', 'textfields', 'chips', 'sliders', 'loading', 'navigation'];
const themes = ['purple', 'teal', 'blue'];
const here = fileURLToPath(new URL('.', import.meta.url));
const root = resolve(here, '../..');
const output = resolve(root, 'doc/assets/gifs');
const baseUrl = process.env.MORPH_GIF_URL ?? 'http://127.0.0.1:8765/';
const fps = Number(process.env.MORPH_GIF_FPS ?? 15);
const seconds = Number(process.env.MORPH_GIF_SECONDS ?? 4.8);
const delayMs = 400;
const onlyAt = process.argv.indexOf('--only');
const selected = onlyAt >= 0 ? [process.argv[onlyAt + 1]] : scenarios;

if (!selected.length || selected.some((s) => !scenarios.includes(s))) {
  console.error(`Escena inválida. Valores: ${scenarios.join(', ')}`);
  process.exit(2);
}
if (!Number.isInteger(fps) || fps < 8 || fps > 30 ||
    !Number.isFinite(seconds) || seconds < 4.5 || seconds > 12) {
  console.error('Configura MORPH_GIF_FPS=8..30 y MORPH_GIF_SECONDS=4.5..12.');
  process.exit(2);
}

function run(command, args) {
  const result = spawnSync(command, args, { stdio: 'inherit' });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`${command} terminó con código ${result.status}`);
  }
}

const sleep = (ms) => new Promise((resolveSleep) => setTimeout(resolveSleep, ms));
let browser;
try {
  await mkdir(output, { recursive: true });
  browser = await chromium.launch({
    headless: true,
    ...(process.env.MORPH_GIF_BROWSER ? { executablePath: process.env.MORPH_GIF_BROWSER } : {}),
  });
  for (const [index, name] of selected.entries()) {
    console.log(`\n[gif] ${name}: capturando ${seconds}s @ ${fps} fps`);
    const temporary = await mkdtemp(join(tmpdir(), `morph-${name}-`));
    const context = await browser.newContext({
      viewport: { width: 640, height: 360 },
      deviceScaleFactor: 1,
      reducedMotion: 'no-preference',
      colorScheme: 'dark',
    });
    try {
      const page = await context.newPage();
      const url = new URL(baseUrl);
      url.searchParams.set('capture', name);
      url.searchParams.set('theme', themes[index % themes.length]);
      url.searchParams.set('delayMs', String(delayMs));
      await page.goto(url.href, { waitUntil: 'domcontentloaded', timeout: 60000 });
      // Flutter web monta <flutter-view> cuando su motor está activo.
      await page.locator('flutter-view').waitFor({ state: 'visible', timeout: 60000 });
      await page.addStyleTag({ content: 'html, body, flutter-view, * { cursor: none !important; }' });
      await page.mouse.move(639, 359);
      await page.waitForTimeout(220);

      const frames = Math.ceil(seconds * fps);
      const start = performance.now();
      for (let frame = 0; frame < frames; frame++) {
        const next = start + frame * (1000 / fps);
        await sleep(Math.max(0, next - performance.now()));
        await page.screenshot({
          path: join(temporary, `frame_${String(frame).padStart(4, '0')}.png`),
          type: 'png',
          animations: 'allow',
          caret: 'hide',
          timeout: 30000,
        });
      }

      // Paleta adaptativa a cada clip para un GIF moderado sin banding severo.
      const filename = join(output, `${name}.gif`);
      run('ffmpeg', [
        '-hide_banner', '-loglevel', 'error', '-y',
        '-framerate', String(fps),
        '-i', join(temporary, 'frame_%04d.png'),
        '-filter_complex',
        '[0:v]split[a][b];[a]palettegen=max_colors=112:stats_mode=diff[p];' +
          '[b][p]paletteuse=dither=bayer:bayer_scale=4:diff_mode=rectangle[v]',
        '-map', '[v]', '-loop', '0', filename,
      ]);
      console.log(`[gif] ✓ ${filename}`);
    } finally {
      await context.close();
      await rm(temporary, { recursive: true, force: true });
    }
  }
  console.log(`\n[gif] ${selected.length} GIF(s) en doc/assets/gifs/`);
} finally {
  await browser?.close();
}
