// CategoryPage.ets
import router from '@ohos.router';
import { ComponentContent, LengthMetrics } from "@kit.ArkUI";
import { UIContext } from '@kit.ArkUI';
import { ArcList, ArcListItem, ArcListAttribute, ArcListItemAttribute } from '@kit.ArkUI';

@Builder
function buildHeader() {
  Column() {
    Image($r('app.media.arrow_left'))
      .width(30)
      .height(30)
      .margin({ bottom: 18 })
      .onClick(() => {
        router.replaceUrl({ url: 'pages/HomePage' })
      })
      .alignSelf(ItemAlign.Center)

    Text("Choose Category")
      .fontSize('28px')
      .fontWeight(FontWeight.Bold)
      .fontColor(Color.Black)
      .textAlign(TextAlign.Center)
      .width('100%')
  }
}

@Entry
@Component
struct CategoryPage {
  @State private categories: string[] = ['City', 'Animal', 'Food'];
  private watchSize: string = '466px';
  private listSize: string = '360px';

  context: UIContext = this.getUIContext();
  headerBar: ComponentContent<LengthMetrics> =
    new ComponentContent<LengthMetrics>(this.context, wrapBuilder(buildHeader));

  private get howToPlay(): string {
    return "This is a 3x3 reveal puzzle. Tap tiles to reveal parts of the image and try to guess the answer. The fewer tiles you open, the higher your score.";
  }

  @Builder
  buildArcMenu() {
    Stack() {
      Column() {}
      .justifyContent(FlexAlign.Center)
      .width(this.watchSize)
      .height(this.watchSize)
      .borderRadius(this.watchSize)
      .clip(true)
      .backgroundColor(Color.White)

      ArcList({ initialIndex: 0, header: this.headerBar }) {
        ForEach(this.categories, (item: string, index: number) => {
          ArcListItem() {
            Button(item, { type: ButtonType.Capsule })
              .width(this.listSize)
              .height('80px')
              .fontSize('24px')
              .focusable(true)
              .focusOnTouch(true)
              .backgroundColor(0x17A98D)
              .fontColor(Color.White)
              .onClick(() => {
                AlertDialog.show({
                  title: "How to Play",
                  message: this.howToPlay,
                  primaryButton: {
                    value: "Understood",
                    action: () => {
                      router.pushUrl({
                        url: 'pages/GamePage',
                        params: { category: item }
                      });
                    }
                  },
                  cancel: () => {}
                });
              })
          }
          .align(Alignment.Center)
        }, (item: string, index: number) => item + index)
      }
      .borderRadius(this.watchSize)
      .focusable(true)
      .focusOnTouch(true)
      .defaultFocus(true)
    }
    .align(Alignment.Center)
    .width(this.watchSize)
    .height(this.watchSize)
    .border({ color: Color.Black, width: 1 })
    .borderRadius(this.watchSize)
    .clip(true)
  }

  build() {
    Column() {
      this.buildArcMenu()
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
  }
}
