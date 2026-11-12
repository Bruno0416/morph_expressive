#!/usr/bin/env node
/**
 * Captura escenas de Flutter Web sin puntero y produce GIFs optimizados.
 * Las escenas animan sus propios controles; Playwright solo captura frames.
 *
 * Los frames salen del screencast del compositor (unos 60 por segundo, con la
 * marca de tiempo real de cada uno) y se muestrean en una rejilla uniforme de
 * 1/fps. Con fps <= 50 no se duplica ni se interpola ningun frame: cada frame
 * del GIF es el ultimo frame real producido hasta ese instante, de modo que la
 * velocidad de reproduccion coincide con la animacion real.
 * Uso interno: invocado por tool/generate_component_gifs.sh.
 */
import { chromium } from 'playwright';
import { spawnSync } from 'node:child_process';
import { mkdtemp, mkdir, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

// The 14 README GIFs. `navigation_rail_drawer` is kept for its own guide only
// (doc/NAVIGATION_MORPH.md); it is not part of the default set.
const scenarios = ['buttons', 'chips', 'dialogs', 'dropdown', 'lists', 'loading', 'navigation', 'segmented', 'sliders', 'textfields', 'async_button', 'skeleton', 'tabs', 'fab_menu'];
const guideScenarios = ['navigation_rail_drawer'];
const themes = ['purple', 'teal', 'blue'];
const here = fileURLToPath(new URL('.', import.meta.url));
const root = resolve(here, '../..');
const output = resolve(root, 'doc/assets/gifs');
const baseUrl = process.env.MORPH_GIF_URL ?? 'http://127.0.0.1:8765/';
const fps = Number(process.env.MORPH_GIF_FPS ?? 15);
// GIF stores delays in centiseconds: 50 fps (20 ms) is the fastest uniform rate.
const maxFps = 50;
// Scenes whose effective renderer is verified outside the image.
const requiredRenderer = { navigation_rail_drawer: ['organic_stretch', 'shader'] };
const sceneSettings = {
  chips: { width: 640, height: 340, seconds: 8.7, theme: 'teal', fps: 25 },
  textfields: { width: 640, height: 420, seconds: 8.2, theme: 'purple', fps: 25 },
  lists: { width: 640, height: 340, seconds: 5.8, theme: 'purple', fps: 50 },
  dialogs: { width: 640, height: 360, seconds: 6.5, theme: 'blue', fps: 25 },
  sliders: { width: 640, height: 360, seconds: 6.8, theme: 'purple', fps: 50 },
  dropdown: { width: 640, height: 320, seconds: 4.8, theme: 'purple', fps: 50 },
  loading: { width: 640, height: 310, seconds: 8, theme: 'teal', fps: 50 },
  buttons: { width: 640, height: 370, seconds: 7.2, theme: 'purple', fps: 50, colors: 96, dither: 'none' },
  segmented: { width: 640, height: 350, seconds: 7.2, theme: 'purple', fps: 50 },
  navigation: { width: 640, height: 350, seconds: 7.2, theme: 'purple', fps: 50 },
  async_button: { width: 640, height: 340, seconds: 10.6, theme: 'teal', fps: 50 },
  skeleton: { width: 640, height: 340, seconds: 8.3, theme: 'blue', fps: 50, colors: 48, dither: 'none' },
  tabs: { width: 640, height: 380, seconds: 7.5, theme: 'purple', fps: 50 },
  fab_menu: { width: 640, height: 400, seconds: 7.7, theme: 'teal', fps: 50 },
  navigation_rail_drawer: { width: 640, height: 380, seconds: 7.6, theme: 'teal', fps: 50 },
};
// The recording starts this long after the scene marks its own start, once the
// shader programs and fonts have had time to load.
const delayMs = 1500;
const secondsOverride = process.env.MORPH_GIF_SECONDS;
const requested = process.argv.flatMap((arg, index, args) =>
  arg === '--only' ? [args[index + 1]] : []);
const selected = requested.length ? [...new Set(requested)] : scenarios;

if (!selected.length || selected.some((s) => !scenarios.includes(s) && !guideScenarios.includes(s))) {
  console.error(`Escena inválida. Valores: ${[...scenarios, ...guideScenarios].join(', ')}`);
  process.exit(2);
}
if (!Number.isInteger(fps) || fps < 8 || fps > maxFps ||
    selected.some((name) => {
      const seconds = Number(secondsOverride ?? sceneSettings[name]?.seconds ?? 4.8);
      return !Number.isFinite(seconds) || seconds < 4.5 || seconds > 12;
    })) {
  console.error('Configura MORPH_GIF_FPS=8..50 y MORPH_GIF_SECONDS=4.5..12.');
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
    const sceneFps = Number(process.env.MORPH_GIF_FPS ?? settings.fps ?? 15);
    console.log(`\n[gif] ${name}: ${settings.width}x${settings.height}, ${seconds}s @ ${sceneFps} fps`);
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
      const renderers = new Map();
      page.on('console', (message) => {
        const found = message.text().match(/MORPH_GIF_RENDERER (\w+)=(\w+)/);
        if (found) renderers.set(found[1], found[2]);
      });
      const started = new Promise((resolveStart) =>
        page.on('console', (message) => {
          if (message.text().includes('MORPH_GIF_SCENE_START')) resolveStart();
        }));
      await page.goto(url.href, { waitUntil: 'domcontentloaded', timeout: 60000 });
      // Flutter web monta <flutter-view> cuando su motor está activo.
      await page.locator('flutter-view').waitFor({ state: 'visible', timeout: 60000 });
      await page.addStyleTag({ content: 'html, body, flutter-view, * { cursor: none !important; }' });
      await page.mouse.move(settings.width - 1, settings.height - 1);
      // Recording begins just before the scripted sequence (the rest state
      // first, so the loop joins back to the same state).
      await started;
      await page.waitForTimeout(delayMs - 300);

      const cdp = await context.newCDPSession(page);
      const captured = [];
      cdp.on('Page.screencastFrame', (frame) => {
        captured.push({ t: frame.metadata.timestamp, data: Buffer.from(frame.data, 'base64') });
        cdp.send('Page.screencastFrameAck', { sessionId: frame.sessionId }).catch(() => {});
      });
      await cdp.send('Page.startScreencast', { format: 'png', everyNthFrame: 1 });
      await sleep(seconds * 1000 + 250);
      await cdp.send('Page.stopScreencast');
      if (captured.length < 2) throw new Error(`${name}: el compositor no produjo frames`);

      // Uniform grid: each GIF frame is the last real frame produced so far.
      const frames = Math.floor(seconds * sceneFps);
      const t0 = captured[0].t;
      let cursor = 0;
      let reused = 0;
      let previous = -1;
      for (let frame = 0; frame < frames; frame++) {
        const at = t0 + frame / sceneFps;
        while (cursor + 1 < captured.length && captured[cursor + 1].t <= at) cursor++;
        if (cursor === previous) reused++;
        previous = cursor;
        await writeFile(join(temporary, `frame_${String(frame).padStart(4, '0')}.png`), captured[cursor].data);
      }
      const realFps = (captured.length - 1) / (captured.at(-1).t - t0);
      // A static tail produces no compositor frames: the last real frame holds.
      console.log(
        `[gif] ${name}: ${captured.length} frames del compositor (${realFps.toFixed(1)} fps reales), ` +
          `${frames} frames GIF a ${sceneFps} fps, ${reused} repetidos por estar la pantalla quieta`);
      const encodeFps = sceneFps;
      for (const [component, effective] of renderers) {
        console.log(`[gif] ${name}: renderer efectivo ${component} = ${effective}`);
      }
      const need = requiredRenderer[name];
      if (need && renderers.get(need[0]) !== need[1]) {
        throw new Error(`${name}: se esperaba ${need[0]}=${need[1]} y se obtuvo ${renderers.get(need[0]) ?? 'sin diagnostico'}`);
      }
      // Paleta adaptativa a cada clip para un GIF moderado sin banding severo.
      const filename = join(output, `${name}.gif`);
      run('ffmpeg', [
        '-hide_banner', '-loglevel', 'error', '-y',
        '-framerate', String(encodeFps),
        '-i', join(temporary, 'frame_%04d.png'),
        '-filter_complex',
        `[0:v]split[a][b];[a]palettegen=max_colors=${process.env.MORPH_GIF_COLORS ?? settings.colors ?? 112}:stats_mode=diff[p];` +
          `[b][p]paletteuse=dither=${process.env.MORPH_GIF_DITHER ?? settings.dither ?? 'bayer'}${(process.env.MORPH_GIF_DITHER ?? settings.dither) ? '' : ':bayer_scale=4'}:diff_mode=rectangle[v]`,
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
