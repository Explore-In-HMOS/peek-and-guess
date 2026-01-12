// CategoryPage.ets
import { UIContext } from '@kit.ArkUI';

interface GamePageParams {
  category: string;
}

@Builder
function buildHeader() {
  Column() {
    Image($r('app.media.arrow_left'))
      .width(30)
      .height(30)
      .margin({ bottom: 18 })
      .fillColor(Color.Black)
      .alignSelf(ItemAlign.Center)

    Text('Choose Category')
      .fontSize('28px')
      .fontWeight(FontWeight.Bold)
      .fontColor(Color.Black)
      .textAlign(TextAlign.Center)
      .width('100%')
  }
  .padding({ top: 20, bottom: 20 })
}

@Builder
export function CategoryPageBuilder() {
  CategoryPage()
}

@Component
struct CategoryPage {
  @State private categories: string[] = ['City', 'Animal', 'Food'];
  private watchSize: string = '466px';
  private listSize: string = '360px';
  pageInfos: NavPathStack = new NavPathStack()
  uiContext: UIContext = this.getUIContext()

  private get howToPlay(): string {
    return 'This is a 3x3 reveal puzzle. Tap tiles to reveal parts of the image and try to guess the answer. The fewer tiles you open, the higher your score.';
  }

  @Builder
  buildMenu() {
    Column() {
      // Header
      buildHeader()

      // Category List
      List({ space: 15 }) {
        ForEach(this.categories, (item: string, index: number) => {
          ListItem() {
            Button(item, { type: ButtonType.Capsule })
              .width(this.listSize)
              .height('80px')
              .fontSize('24px')
              .focusable(true)
              .focusOnTouch(true)
              .backgroundColor(0x17A98D)
              .fontColor(Color.White)
              .onClick(() => {
                this.uiContext.showAlertDialog({
                  title: 'How to Play',
                  message: this.howToPlay,
                  primaryButton: {
                    value: 'Understood',
                    action: () => {
                      const params: GamePageParams = { category: item };
                      this.pageInfos.pushPathByName('GamePage', params);
                    }
                  },
                  cancel: () => {}
                })
              })
          }
        }, (item: string, index: number) => item)
      }
      .width('100%')
      .layoutWeight(1)
    }
    .width(this.watchSize)
    .height(this.watchSize)
    .backgroundColor(Color.White)
    .borderRadius(this.watchSize)
    .clip(true)
    .justifyContent(FlexAlign.Center)
  }

  build() {
    NavDestination() {
      Column() {
        this.buildMenu()
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
    }
    .hideTitleBar(true)
    .onReady((context: NavDestinationContext) => {
      this.pageInfos = context.pathStack;
    })
    .onBackPressed(() => {
      this.pageInfos.pop();
      return true;
    })
  }
}