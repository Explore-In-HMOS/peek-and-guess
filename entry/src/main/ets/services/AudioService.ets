// ets/services/AudioService.ets
import media from '@ohos.multimedia.media';
import resourceManager from '@ohos.resourceManager';

export type SfxKind = 'correct' | 'wrong' | 'congrats' | 'game_over';

interface AVPlayerWithFD extends media.AVPlayer {
  setSourceFD?(fd: number, offset: number, length: number): Promise<void>;
}

export class AudioService {
  private static rm: resourceManager.ResourceManager | null = null;
  private static readonly players: Map<SfxKind, media.AVPlayer> = new Map();

  private static readonly fileMap: Map<SfxKind, string> = new Map([
    ['correct',   'correct.mp3'],
    ['wrong',     'wrong.mp3'],
    ['congrats',  'congrats.mp3'],
    ['game_over', 'game_over.mp3']
  ]);

  static init(rm: resourceManager.ResourceManager): void {
    AudioService.rm = rm;
  }

  private static fileNameOf(kind: SfxKind): string {
    return AudioService.fileMap.get(kind) ?? 'correct.mp3';
  }

  private static async createPlayerFromRaw(rawName: string): Promise<media.AVPlayer> {
    const rm = AudioService.rm;
    if (!rm) {
      throw new Error('ResourceManager not set. Call AudioService.init(...) first.');
    }

    const player: AVPlayerWithFD = await media.createAVPlayer() as AVPlayerWithFD;

    // Prefer FD (best for rawfile). Fallback to URI if FD method is not present.
    const fdInfo = await rm.getRawFd(rawName);
    if (typeof player.setSourceFD === 'function') {
      await player.setSourceFD(fdInfo.fd, fdInfo.offset, fdInfo.length);
    } else {

      throw new Error('AVPlayer.setSourceFD is unavailable on this device/API.');
    }

    await (player as media.AVPlayer).prepare();
    try { (player as media.AVPlayer).loop = false; } catch {}


    rm.closeRawFdSync(rawName);
    return player as media.AVPlayer;
  }

  private static async rewind(player: media.AVPlayer): Promise<void> {
    try {
      await player.pause();
    } catch {}
    try {
      await player.seek(0);
    } catch {
      try { await player.stop(); } catch {}
    }
  }

  static async play(kind: SfxKind): Promise<void> {
    if (!AudioService.rm) {
      return;
    }

    let player = AudioService.players.get(kind);
    if (!player) {
      const fileName = AudioService.fileNameOf(kind);
      player = await AudioService.createPlayerFromRaw(fileName);
      AudioService.players.set(kind, player);
    }

    await AudioService.rewind(player);
    await player.play();
  }

  static async releaseAll(): Promise<void> {
    const list = Array.from(AudioService.players.values());
    for (const p of list) {
      try { await p.stop(); } catch {}
      try { await p.release(); } catch {}
    }
    AudioService.players.clear();
  }
}

export default AudioService;
