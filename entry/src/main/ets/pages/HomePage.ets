// HomePage.ets
import { CategoryPageBuilder } from './CategoryPage';
import { GamePageBuilder } from './GamePage';

@Entry({ routeName: 'HomePage' })
@Component
struct HomePage {
  pageInfos: NavPathStack = new NavPathStack()

  @Builder
  PageMap(name: string) {
    if (name === 'CategoryPage') {
      CategoryPageBuilder()
    } else if (name === 'GamePage') {
      GamePageBuilder()
    }
  }

  build() {
    Navigation(this.pageInfos) {
      Column({ space: 20 }) {
        Text('Peek &\n Guess')
          .fontSize(32)
          .fontWeight(FontWeight.Bold)
          .fontColor(Color.Black)
          .textAlign(TextAlign.Center)
          .width('100%')



        Text('Think before you reveal, play brave when you guess')
          .fontSize(12)
          .fontColor(0x666666)
          .textAlign(TextAlign.Center)
          .fontStyle(FontStyle.Italic)
          .width('80%')
          .height(20)
          .width(80)
          .margin({bottom:10})


        Button('Start')
          .width(100)
          .height(45)
          .fontSize(20)
          .borderRadius(12)
          .backgroundColor(Color.Black)
          .fontColor(Color.White)
          .margin({ top: 30 })
          .onClick(() => {
            this.pageInfos.pushPathByName('CategoryPage', null);
          })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Center)
      .justifyContent(FlexAlign.Center)
      .backgroundColor(Color.White)
    }
    .navDestination(this.PageMap)
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
  }
}