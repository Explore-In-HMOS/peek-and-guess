// ets/services/HapticsService.ets
import { vibrator } from '@kit.SensorServiceKit';
import { BusinessError } from '@kit.BasicServicesKit';

const PRESET_CLICK = 'haptic.general.click';
const PRESET_SUCCESS = 'haptic.notice.success';
const PRESET_FAILURE = 'haptic.notice.failure';

function isEffectSupported(effectId: string): Promise<boolean> {
  return new Promise<boolean>((resolve) => {
    try {
      vibrator.isSupportEffect(effectId, (err: BusinessError, state: boolean) => {
        if (err) {
          resolve(false);
          return;
        }
        resolve(state === true);
      });
    } catch (_e) {
      resolve(false);
    }
  });
}

function startVibrationPreset(effectId: string, usage: 'touch' | 'notification' | 'alarm' | 'ring' = 'touch'): Promise<void> {
  return new Promise<void>((resolve, reject) => {
    try {
      vibrator.startVibration(
        {
          type: 'preset',
          effectId,
          count: 1
        },
        {
          usage
        },
        (err: BusinessError) => {
          if (err) {
            reject(err);
            return;
          }
          resolve();
        }
      );
    } catch (e) {
      reject(e as BusinessError);
    }
  });
}

function startVibrationTime(durationMs: number, usage: 'touch' | 'notification' | 'alarm' | 'ring' = 'touch'): Promise<void> {
  return new Promise<void>((resolve, reject) => {
    try {
      vibrator.startVibration(
        {
          type: 'time',
          duration: durationMs
        },
        {
          id: 0,
          usage
        },
        (err: BusinessError) => {
          if (err) {
            reject(err);
            return;
          }
          resolve();
        }
      );
    } catch (e) {
      reject(e as BusinessError);
    }
  });
}

export class HapticsService {

  private static async vibrateSmart(presetId: string, fallbackMs: number, usage: 'touch' | 'notification' | 'alarm' | 'ring' = 'touch'): Promise<void> {
    try {
      const supported = await isEffectSupported(presetId);
      if (supported) {
        await startVibrationPreset(presetId, usage);
        return;
      }
      await startVibrationTime(fallbackMs, usage);
    } catch (e) {
      const be = e as BusinessError;
      console.warn(`[HapticsService] vibrateSmart failed for ${presetId}: ${be?.code ?? ''} ${be?.message ?? be}`);
    }
  }

  // short notification feedback
  static async tick(): Promise<void> {
    // first click press
    await HapticsService.vibrateSmart(PRESET_CLICK, 25, 'touch');
  }

  // correct feedback
  static async correct(): Promise<void> {
    // Başta success preset dene; yoksa time pattern uygula
    const supported = await isEffectSupported(PRESET_SUCCESS);
    if (supported) {
      await startVibrationPreset(PRESET_SUCCESS, 'notification');
      return;
    }
    await startVibrationTime(30, 'touch');
    setTimeout(() => { void startVibrationTime(40, 'touch'); }, 80);
  }

  // wrong feedback
  static async wrong(): Promise<void> {
    const supported = await isEffectSupported(PRESET_FAILURE);
    if (supported) {
      await startVibrationPreset(PRESET_FAILURE, 'notification');
      return;
    }
    await startVibrationTime(140, 'touch');
  }

  // win situation
  static async win(): Promise<void> {
    const supported = await isEffectSupported(PRESET_SUCCESS);
    if (supported) {
      await startVibrationPreset(PRESET_SUCCESS, 'notification');
      return;
    }
    await startVibrationTime(50, 'touch');
    setTimeout(() => { void startVibrationTime(60, 'touch'); }, 120);
    setTimeout(() => { void startVibrationTime(80, 'touch'); }, 260);
  }

  // lost situation
  static async lose(): Promise<void> {
    const supported = await isEffectSupported(PRESET_FAILURE);
    if (supported) {
      await startVibrationPreset(PRESET_FAILURE, 'notification');
      return;
    }
    await startVibrationTime(220, 'touch');
  }
}

export default HapticsService;
