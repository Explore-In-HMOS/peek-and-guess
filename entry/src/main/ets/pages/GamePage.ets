// GamePage.ets
import router from '@ohos.router';
import HapticsService from '../services/HapticsService';
import AudioService from '../services/AudioService';
import common from '@ohos.app.ability.common';

enum Category {
  Animal = 'Animal',
  Food   = 'Food',
  City   = 'City',
}

interface GameParams {
  category?: string;
}

interface PickResult<T> {
  value: T;
  index: number;
}

@Entry
@Component
struct GamePage {
  // grid helpers
  @State private nums: string[] = ['0', '1', '2'];

  // game state
  @State private revealed: boolean[] = new Array<boolean>(9).fill(false);
  @State private gameOver: boolean = false;
  @State private showGuess: boolean = false;
  @State private showWin: boolean = false;
  @State private guessText: string = '';

  // chosen content
  @State private chosenImage: Resource | null = null;
  @State private chosenIndex: number = 0;

  private audioReady: boolean = false;

  private readonly category: Category = (() => {
    const p = router.getParams() as GameParams | undefined;
    const raw = (p?.category ?? '').toString();
    if (raw === Category.Animal || raw === Category.Food || raw === Category.City) {
      return raw as Category;
    }
    return Category.Animal;
  })();

  private readonly images: Map<Category, Resource[]> = new Map<Category, Resource[]>([
    [Category.Animal, [
      $r('app.media.lion'),
      $r('app.media.tiger'),
      $r('app.media.elephant')
    ]],
    [Category.Food, [
      $r('app.media.pizza'),
      $r('app.media.sushi'),
      $r('app.media.burger')
    ]],
    [Category.City, [
      $r('app.media.paris'),
      $r('app.media.kyoto'),
      $r('app.media.philly')
    ]],
  ]);

  private readonly labels: Map<Category, string[]> = new Map<Category, string[]>([
    [Category.Animal, ['lion', 'tiger', 'elephant']],
    [Category.Food,   ['pizza', 'sushi', 'burger']],
    [Category.City,   ['paris', 'kyoto', 'philly']],
  ]);

  private getAt<T>(arr: T[], idx: number): T {
    return arr.slice(idx, idx + 1)[0];
  }

  private pickRandom<T>(arr: T[]): PickResult<T> {
    const len: number = arr.length;
    const idx: number = Math.floor(Math.random() * len);
    const val: T = this.getAt(arr, idx);
    return { value: val, index: idx };
  }

  private startNewRound(): void {
    const pool: Resource[] = this.images.get(this.category) ?? [];
    const picked: PickResult<Resource> = this.pickRandom<Resource>(pool);

    this.chosenIndex = picked.index;
    this.chosenImage = picked.value;

    this.revealed = new Array<boolean>(9).fill(false);
    this.gameOver = false;
    this.showGuess = false;
    this.showWin = false;
    this.guessText = '';
  }

  aboutToAppear(): void {
    // init audio once
    if (!this.audioReady) {
      try {
        const ctx = getContext(this) as common.UIAbilityContext;
        const rm = ctx.resourceManager;
        AudioService.init(rm);
        this.audioReady = true;
      } catch (e) {
        console.warn('[GamePage] AudioService init failed:', e);
      }
    }
    this.startNewRound();
    void HapticsService.tick();
  }

  private getIndex(rIdx?: number, cIdx?: number): number {
    const r: number = rIdx ?? 0;
    const c: number = cIdx ?? 0;
    return r * 3 + c;
  }

  private revealTile(tileId: number): void {
    if (this.gameOver || this.revealed[tileId]) { return; }
    const next: boolean[] = [...this.revealed];
    next[tileId] = true;
    this.revealed = next;
    void HapticsService.tick();
  }

  @Builder
  private Tile(i: number) {
    GridItem({ style: GridItemStyle.PLAIN }) { }
    .backgroundColor(0xFFD966)
    .border({ width: 0.5, color: 0x000000 })
    .borderRadius(0)
    .opacity(this.revealed[i] ? 0 : 1)
    .onClick(() => {
      animateTo({ duration: 200 }, () => this.revealTile(i));
    });
  }

  private submitGuess(): void {
    const labelPool: string[] = this.labels.get(this.category) ?? [];
    const expected: string = (this.getAt(labelPool, this.chosenIndex) ?? '').toLowerCase();
    const user: string = (this.guessText || '').trim().toLowerCase();

    this.showGuess = false;

    if (user && user === expected) {
      this.showWin = true;
      this.gameOver = true;
      void HapticsService.correct();
      void AudioService.play('correct');
      setTimeout(() => { void AudioService.play('congrats'); }, 250);
    } else {
      void HapticsService.wrong();
      void AudioService.play('wrong');
    }
  }

  private revealAllTiles(): void {
    const next: boolean[] = new Array<boolean>(9).fill(true);
    this.revealed = next;
    this.gameOver = true;
    void HapticsService.lose();
    void AudioService.play('game_over');
  }

  build() {
    Stack() {
      Column() {
        // Header
        Column() {
          Image($r('app.media.arrow_left'))
            .width(20).height(20)
            .fillColor(Color.White)
            .onClick(() => router.back())
            .margin({ bottom: 5 })
            .alignSelf(ItemAlign.Center)

          Text(this.category)
            .fontSize(22)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .width('100%')
        }
        .width('100%')
        .alignItems(HorizontalAlign.Center)

        // Puzzle area
        Stack() {
          if (this.chosenImage) {
            Image(this.chosenImage)
              .width('60%')
              .height('60%')
              .objectFit(ImageFit.Cover)
          }

          Grid() {
            ForEach(this.nums, (_r: string, rIdx?: number) => {
              ForEach(this.nums, (_c: string, cIdx?: number) => {
                this.Tile(this.getIndex(rIdx, cIdx));
              }, (_c2: string, cIdx2?: number) => `r${rIdx}-c${cIdx2}`)
            }, (_r2: string, rIdx2?: number) => `r${rIdx2}`)
          }
          .columnsTemplate('1fr 1fr 1fr')
          .rowsTemplate('1fr 1fr 1fr')
          .width('60%')
          .height('60%')
        }

        Row({ space: 10 }) {
          Button("Guess")
            .fontSize(8)
            .backgroundColor(0x007AFF)
            .fontColor(Color.White)
            .width(60)
            .height(16)
            .borderRadius(4)
            .onClick(() => {
              this.showGuess = true;
              void HapticsService.tick();
            })

          Button("Reveal")
            .fontSize(8)
            .backgroundColor(0x34C759)
            .fontColor(Color.White)
            .width(60)
            .height(16)
            .borderRadius(4)
            .onClick(() => this.revealAllTiles())
        }
        .justifyContent(FlexAlign.Center)
        .width('100%')
        .padding({ bottom: 10 })
      }
      .width('100%')

      // Guess input overlay
      if (this.showGuess) {
        Column() { }
        .width('100%')
        .height('100%')
        .backgroundColor(0x80000000)

        Column() {
          Text('Type your guess')
            .fontSize(14)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .fontColor(Color.Black)
            .width('100%')
            .margin({ bottom: 8 })

          TextInput({ placeholder: 'e.g., lion / sushi / paris' })
            .width('100%')
            .height(30)
            .border({ width: 1, color: 0xCCCCCC })
            .padding(3)
            .fontColor(Color.Black)
            .onChange((v: string) => { this.guessText = v; })

          Row({ space: 8 }) {
            Button('Submit')
              .fontSize(10)
              .width(70)
              .height(22)
              .borderRadius(12)
              .backgroundColor(0x007AFF)
              .fontColor(Color.White)
              .onClick(() => this.submitGuess())

            Button('Cancel')
              .fontSize(10)
              .width(70)
              .height(22)
              .borderRadius(12)
              .backgroundColor(0xAAAAAA)
              .fontColor(Color.White)
              .onClick(() => {
                this.showGuess = false;
                this.guessText = '';
                void HapticsService.tick();
              })
          }
          .justifyContent(FlexAlign.SpaceBetween)
          .margin({ top: 15 })
        }
        .width(180)
        .height(120)
        .padding(12)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .alignSelf(ItemAlign.Center)
      }

      // Win overlay
      if (this.showWin) {
        Column() { }
        .width('100%')
        .height('100%')
        .backgroundColor(0x80000000)

        Column() {
          Text('You Win!')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .textAlign(TextAlign.Center)
            .fontColor(Color.Green)
            .width('100%')

          Button('Next round')
            .fontSize(10)
            .width(100)
            .height(22)
            .borderRadius(14)
            .margin({ top: 12 })
            .backgroundColor(0x34C759)
            .fontColor(Color.White)
            .onClick(() => this.startNewRound())

          Button('Back to categories')
            .fontSize(10)
            .width(120)
            .height(22)
            .borderRadius(14)
            .margin({ top: 6 })
            .backgroundColor(0x007AFF)
            .fontColor(Color.White)
            .onClick(() => router.replaceUrl({ url: 'pages/CategoryPage' }))
        }
        .width(180)
        .height(120)
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .alignSelf(ItemAlign.Center)
      }

      // Game-over overlay
      if (this.gameOver && !this.showWin) {
        Column() { }
        .width('100%')
        .height('100%')
        .backgroundColor(0x80000000)

        Column() {
          Text('Game Over!')
            .fontSize(15)
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.Red)
            .textAlign(TextAlign.Center)
            .width('100%')

          Button('Play again')
            .fontSize(10)
            .width(100)
            .height(22)
            .borderRadius(14)
            .fontColor(Color.White)
            .backgroundColor(0x34C759)
            .margin({ top: 12 })
            .onClick(() => this.startNewRound())

          Button('Close')
            .fontSize(10)
            .width(85)
            .height(22)
            .borderRadius(14)
            .margin({ top: 6 })
            .backgroundColor(0x007AFF)
            .fontColor(Color.White)
            .onClick(() => {
              this.gameOver = false;
              void HapticsService.tick();
            })
        }
        .width(180)
        .height(120)
        .padding(16)
        .backgroundColor(Color.White)
        .borderRadius(10)
        .alignSelf(ItemAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
