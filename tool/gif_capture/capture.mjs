#!/usr/bin/env node
/**
 * Captures Flutter Web scenes (no visible pointer) and produces optimized GIFs.
 * The scenes drive their own controls; Playwright only records frames.
 *
 * Frames come from the compositor screencast (about 60 per second, each with
 * its real timestamp) and are sampled on a uniform 1/fps grid. With fps <= 50
 * no frame is duplicated or interpolated: every GIF frame is the last real
 * frame produced up to that instant, so playback speed matches the real
 * animation.
 * Internal use: invoked by tool/generate_component_gifs.sh.
 */
import { chromium } from 'playwright';
import { spawnSync } from 'node:child_process';
import { mkdtemp, mkdir, rm, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

// The default set (every scene the documentation may use). The README picks a
// subset; tool/check_gif_branding.py holds the curated list.
// `navigation_rail_drawer` is kept for its own guide only (doc/NAVIGATION_MORPH.md).
const scenarios = ['buttons', 'chips', 'dialogs', 'dropdown', 'lists', 'loading', 'navigation', 'segmented', 'sliders', 'textfields', 'async_button', 'skeleton', 'tabs', 'fab_menu', 'variants', 'density', 'context_menu'];
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
// Every showcase is 16:9 (640x360) at a GIF-exact rate (25 fps = 4 cs, 50 fps = 2 cs).
// Scenes with time-based loops (wavy tracks, loading indicator) last a whole
// number of seconds so the clip joins seamlessly.
const sceneSettings = {
  buttons: { width: 640, height: 360, seconds: 7, theme: 'purple', fps: 25 },
  dropdown: { width: 640, height: 360, seconds: 7, theme: 'purple', fps: 25 },
  segmented: { width: 640, height: 360, seconds: 7, theme: 'purple', fps: 25 },
  textfields: { width: 640, height: 360, seconds: 7, theme: 'purple', fps: 25 },
  chips: { width: 640, height: 360, seconds: 7.5, theme: 'teal', fps: 25 },
  sliders: { width: 640, height: 360, seconds: 7, theme: 'purple', fps: 25 },
  loading: { width: 640, height: 360, seconds: 7, theme: 'teal', fps: 25, colors: 128, dither: 'none' },
  navigation: { width: 640, height: 360, seconds: 7, theme: 'purple', fps: 25 },
  // Existing scenes kept as they were.
  lists: { width: 640, height: 340, seconds: 5.8, theme: 'purple', fps: 50 },
  dialogs: { width: 640, height: 360, seconds: 6.5, theme: 'blue', fps: 25 },
  async_button: { width: 640, height: 340, seconds: 10.6, theme: 'teal', fps: 50 },
  skeleton: { width: 640, height: 340, seconds: 8.3, theme: 'blue', fps: 50, colors: 48, dither: 'none' },
  tabs: { width: 640, height: 380, seconds: 7.5, theme: 'purple', fps: 50 },
  fab_menu: { width: 640, height: 400, seconds: 7.7, theme: 'teal', fps: 50 },
  navigation_rail_drawer: { width: 640, height: 380, seconds: 7.6, theme: 'teal', fps: 50 },
  variants: { width: 640, height: 360, seconds: 6, theme: 'purple', fps: 50 },
  density: { width: 640, height: 360, seconds: 6.6, theme: 'purple', fps: 25 },
  context_menu: { width: 640, height: 360, seconds: 7.2, theme: 'blue', fps: 50 },
};
// The recording starts this long after the scene marks its own start, once the
// shader programs and fonts have had time to load.
const delayMs = 1500;
const secondsOverride = process.env.MORPH_GIF_SECONDS;
const requested = process.argv.flatMap((arg, index, args) =>
  arg === '--only' ? [args[index + 1]] : []);
const selected = requested.length ? [...new Set(requested)] : scenarios;

if (!selected.length || selected.some((s) => !scenarios.includes(s) && !guideScenarios.includes(s))) {
  console.error(`Invalid scene. Values: ${[...scenarios, ...guideScenarios].join(', ')}`);
  process.exit(2);
}
if (!Number.isInteger(fps) || fps < 8 || fps > maxFps ||
    selected.some((name) => {
      const seconds = Number(secondsOverride ?? sceneSettings[name]?.seconds ?? 4.8);
      return !Number.isFinite(seconds) || seconds < 4.5 || seconds > 12;
    })) {
  console.error('Set MORPH_GIF_FPS=8..50 and MORPH_GIF_SECONDS=4.5..12.');
  process.exit(2);
}

function run(command, args) {
  const result = spawnSync(command, args, { stdio: 'inherit' });
  if (result.error) throw result.error;
  if (result.status !== 0) {
    throw new Error(`${command} exited with code ${result.status}`);
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
      // Flutter web mounts <flutter-view> once its engine is running.
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
      if (captured.length < 2) throw new Error(`${name}: the compositor produced no frames`);

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
        `[gif] ${name}: ${captured.length} compositor frames (${realFps.toFixed(1)} real fps), ` +
          `${frames} GIF frames at ${sceneFps} fps, ${reused} repeated while the screen was still`);
      const encodeFps = sceneFps;
      for (const [component, effective] of renderers) {
        console.log(`[gif] ${name}: effective renderer ${component} = ${effective}`);
      }
      const need = requiredRenderer[name];
      if (need && renderers.get(need[0]) !== need[1]) {
        throw new Error(`${name}: expected ${need[0]}=${need[1]} but got ${renderers.get(need[0]) ?? 'no diagnostic'}`);
      }
      // Adaptive palette per clip: a moderate GIF without severe banding.
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
  console.log(`\n[gif] ${selected.length} GIF(s) in doc/assets/gifs/`);
} finally {
  await browser?.close();
}
