# iw01-syhien 杨茂琛 191180164

## 项目概述

实现类似于Apple原生计算器的、支持自动布局与屏幕旋转的单步计算器



## 项目需求

- GUI

- 单步计算
- Autolayout
- 支持屏幕方向旋转
- 支持横屏显示额外计算符



## 开发环境

- macOS Big Sur
- Xcode 13
- Swift 5
- Storyboard



## 项目结构

本节将按照MVC架构对项目进行说明

### Main.storyboard 视图





### ViewController.swift 控制器

ViewController接收storyboad传递而来的事件（如点击buttom等），并依事件的发送者*sender*决定如何处理

#### Outlets

Controller内有两个outlets用于对视图进行修改：

```swift
@IBOutlet weak var resultDisplay: UILabel!
@IBOutlet weak var radButtom: UIButton!
```

`resultDisplay`绑定显示运算数或运算结果的`UILabel`，`radButtom`绑定横屏时的`Rad`按键

#### viewDidLoad()

重写了加载函数（或者说初始化）对`resultDisplay`的`title`预设为空：

```swift
override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
    resultDisplay.text = ""
}
```

#### 与视图和calculator实例的交互

##### 数字

定义一个`typingNow`记录输入状态，实例化`Calculator`类进行计算：

```swift
var typingNow = false
let calculator = Calculator()
```

当按下数字类按键（0到9，小数点）时，方法`numberTouched()`对`resultDisplay.text`更新：

```swift
var typingNow = false
@IBAction func numberTouched(_ sender: UIButton) {
    if typingNow {
        resultDisplay.text = resultDisplay.text! +  sender.currentTitle!
    }
    else {
        resultDisplay.text = sender.currentTitle!
        typingNow = true
    }
}
```

可以看到`numberTouched`方法只会把`typingNow`置为`true`，将`typingNow`置为`false`的工作放在下面的方法`operatorTouched`中进行

##### 运算符

**Note:** 由于要求实现单步的计算器，原生计算器中的`(` `)`未实现

本项目将常量（如自然对数、圆周率等）、等于号也视为运算符，一并交给`Calculator`类进行进一步判断、处理

```swift
@IBAction func operatorTouched(_ sender: UIButton) {
//        print("Buttom \(sender.currentTitle!) touched")
    if let operation  = sender.currentTitle {
        if let result = calculator.performOperation(operation: operation, operand: Double(resultDisplay.text!)!) {
            resultDisplay.text = String(result)
        }
        typingNow = false
    }
}
```

当运算符被touch时，调用`Calculator`类的方法`performOperation`进行计算并得到运算结果，将结果更新到`resultDisplay`并修改`typingNow`表示结束数字输入

一些特殊的运算符没有交给`Calculator`类处理，由`viewController`自身直接处理：

```swift
@IBAction func randTouched(_ sender: UIButton) {
    resultDisplay.text = String(Double.random(in: 0...1))
}
```

点击`Rand`会显示一个`(0,1)`范围内的随机数

**这里要补充MR M+ M-**

**这里要补充RAD**





### Calculator.swift 模型

`Calculator`类实现计算功能，与`viewController`进行互动





## 项目难点





## 参考资料

- [课程slides](https://njuics.github.io/ios2021/#1)
- [实践视频](https://www.bilibili.com/video/BV1Yr4y1c7HW)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- 一些Stackoverflow
- 一些Apple Developer Forum
- 甚至一些CSDN