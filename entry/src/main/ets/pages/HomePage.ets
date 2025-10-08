// HomePage.ets
import router from '@ohos.router';

@Entry
@Component
struct HomePage {
  build() {
    Column({ space: 10 }) {
      Text("Peek &\n Guess")
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.Black)
        .textAlign(TextAlign.Center)
        .width('100%')

      Text("Think before you reveal, play brave when you guess")
        .fontSize(12)
        .fontColor(0x666666)
        .textAlign(TextAlign.Center)
        .fontStyle(FontStyle.Italic)
        .width('80%')

      Button("Start")
        .width(120)
        .height(45)
        .fontSize(20)
        .borderRadius(12)
        .backgroundColor(0x007AFF)
        .fontColor(Color.White)
        .onClick(() => {
          router.pushUrl({ url: 'pages/CategoryPage' })
        })
    }
    .width('100%')
    .height('100%')
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Center)
    .backgroundColor(Color.White)
  }
}
