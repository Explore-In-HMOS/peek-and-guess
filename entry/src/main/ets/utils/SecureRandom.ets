import cryptoFramework from '@ohos.security.cryptoFramework';

const random = cryptoFramework.createRandom();

export function secureRandomInt(min: number, max: number): number {
  const BYTE_LEN: number = 4;
  const bytes = random.generateRandomSync(BYTE_LEN);
  const d = bytes.data;

  const v =
    ((d[0] << 24) >>> 0) |
      ((d[1] << 16) >>> 0) |
      ((d[2] << 8) >>> 0)  |
      (d[3] >>> 0);

  return min + (v % (max - min + 1));
}