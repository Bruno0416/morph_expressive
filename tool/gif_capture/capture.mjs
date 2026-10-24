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

const scenarios = ['buttons', 'dropdown', 'segmented', 'textfields', 'chips', 'sliders', 'loading', 'navigation', 'navigation_morph', 'navigation_rail_drawer', 'lists', 'dialogs'];
const themes = ['purple', 'teal', 'blue'];
const here = fileURLToPath(new URL('.', import.meta.url));
const root = resolve(here, '../..');
const output = resolve(root, 'doc/assets/gifs');
const baseUrl = process.env.MORPH_GIF_URL ?? 'http://127.0.0.1:8765/';
const fps = Number(process.env.MORPH_GIF_FPS ?? 15);
// Taller/longer clips are needed to show all variants and transitions.
// Other scenarios retain the existing 640x360 / 4.8s output.
const sceneSettings = {
  chips: { width: 640, height: 480, seconds: 8.7, theme: 'teal' },
  textfields: { width: 640, height: 480, seconds: 8.2, theme: 'purple' },
  lists: { width: 640, height: 360, seconds: 5.8, theme: 'purple' },
  dialogs: { width: 640, height: 420, seconds: 6.5, theme: 'blue' },
  sliders: { width: 640, height: 360, seconds: 6.8, theme: 'purple' },
  loading: { width: 640, height: 360, seconds: 6.8, theme: 'teal' },
  navigation_morph: { width: 640, height: 520, seconds: 7.2, theme: 'purple' },
  navigation_rail_drawer: { width: 640, height: 500, seconds: 6.8, theme: 'teal' },
};
const secondsOverride = process.env.MORPH_GIF_SECONDS;
const delayMs = 400;
const requested = process.argv.flatMap((arg, index, args) =>
  arg === '--only' ? [args[index + 1]] : []);
const selected = requested.length ? [...new Set(requested)] : scenarios;

if (!selected.length || selected.some((s) => !scenarios.includes(s))) {
  console.error(`Escena inválida. Valores: ${scenarios.join(', ')}`);
  process.exit(2);
}
if (!Number.isInteger(fps) || fps < 8 || fps > 30 ||
    selected.some((name) => {
      const seconds = Number(secondsOverride ?? sceneSettings[name]?.seconds ?? 4.8);
      return !Number.isFinite(seconds) || seconds < 4.5 || seconds > 12;
    })) {
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
    const settings = sceneSettings[name] ?? { width: 640, height: 360, seconds: 4.8 };
    const seconds = Number(secondsOverride ?? settings.seconds);
    console.log(`\n[gif] ${name}: ${settings.width}x${settings.height}, ${seconds}s @ ${fps} fps`);
    const temporary = await mkdtemp(join(tmpdir(), `morph-${name}-`));
    const context = await browser.newContext({
      viewport: { width: settings.width, height: settings.height },
      deviceScaleFactor: 1,
      reducedMotion: 'no-preference',
      colorScheme: 'dark',
    });
    try {
      const page = await context.newPage();
      const url = new URL(baseUrl);
      url.searchParams.set('capture', name);
      url.searchParams.set('theme', settings.theme ?? themes[index % themes.length]);
      url.searchParams.set('delayMs', String(delayMs));
      await page.goto(url.href, { waitUntil: 'domcontentloaded', timeout: 60000 });
      // Flutter web monta <flutter-view> cuando su motor está activo.
      await page.locator('flutter-view').waitFor({ state: 'visible', timeout: 60000 });
      await page.addStyleTag({ content: 'html, body, flutter-view, * { cursor: none !important; }' });
      await page.mouse.move(settings.width - 1, settings.height - 1);
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
