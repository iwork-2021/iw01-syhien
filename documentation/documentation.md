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

```swift
@IBAction func radTouched(_ sender: UIButton) {
    if sender.currentTitle! == "Rad now" {
        radButtom.setTitle("Deg now", for: .normal)
    }
    else {
        radButtom.setTitle("Rad now", for: .normal)
    }
}
```

点击`Rad now`或`Deg now`会更新button显示



### Calculator.swift 模型

`Calculator`类实现计算功能，与`viewController`进行互动

实现了一个`NSObject`的子类`Calculator`：

```swift
class Calculator: NSObject {
}
```

为了抽象运算过程，先对操作符进行枚举：

```swift
enum Operations {
    case UnaryOperation((Double)->Double)
    case BinaryOperation((Double,Double)->Double)
    case EqualOperation
    case Constant(Double)
    case MemoryOperation
}
```

包含了一元运算、二元运算、等于运算、常数类型、存储操作

定义了一个中间结果的结构用于运算：

```swift
struct Intermediate {
    var firstOperand: Double
    var waitingOperation: (Double, Double)->Double
}
var pendingOperation: Intermediate? = nil
```

定义一个`Double memorizedResult`存储计算结果：

```swift
var memorizedResult = 0.0
```

定义了一个操作符的字典，以定义各个操作符的具体行为：

```swift
var operations = [
    "+": Operations.BinaryOperation { $0 + $1 },
    "-": Operations.BinaryOperation { $0 - $1 },
    "*": Operations.BinaryOperation { $0 * $1 },
    "/": Operations.BinaryOperation { $0 / $1 },
    "%": Operations.UnaryOperation { $0 / 100.0},
    "+ / -": Operations.UnaryOperation { -$0 },
    "AC": Operations.Constant(0),
    "=": Operations.EqualOperation,
    "x^2": Operations.UnaryOperation { pow($0, 2) },
    "x^3": Operations.UnaryOperation { pow($0, 3) },
    "x^y": Operations.BinaryOperation { pow($0, $1) },
    "e^x": Operations.UnaryOperation { exp($0) },
    "10^x": Operations.UnaryOperation { pow(10, $0) },
    "1/x": Operations.UnaryOperation { 1 / $0 },
    "square(x)": Operations.UnaryOperation { sqrt($0) },
    "cube(x)": Operations.UnaryOperation { pow($0, 1/3) },
    "x^(1/y)": Operations.BinaryOperation { pow($0, 1/$1) },
    "Ln": Operations.UnaryOperation { log($0) },
    "Lg": Operations.UnaryOperation { log10($0) },
    "x!": Operations.UnaryOperation {
        x in
        switch x {
        case 0:
            return 1
        case 1:
            return 1
        case 2:
            return 2
        case 3:
            return 6
        case 4:
            return 24
        case 5:
            return 120
        case 6:
            return 720
        case 7:
            return 5040
        case 8:
            return 40320
        case 9:
            return 362880
        case 10:
            return 3628800
        case 11:
            return 39916800
        default:
            return -1
        }
        return -1
    },
    "sin": Operations.UnaryOperation { sin($0) },
    "cos": Operations.UnaryOperation { cos($0) },
    "tan": Operations.UnaryOperation { tan($0) },
    "e": Operations.Constant(exp(1)),
    "EE": Operations.BinaryOperation { $0 * pow(10, $1) },
    "sinh": Operations.UnaryOperation { sinh($0) },
    "cosh": Operations.UnaryOperation { cosh($0) },
    "tanh": Operations.UnaryOperation { tanh($0) },
    "π": Operations.Constant(Double.pi),
    "mr": Operations.MemoryOperation,
    "mc": Operations.MemoryOperation,
    "m+": Operations.BinaryOperation { $0 + memorizedResult },
    "m-": Operations.BinaryOperation { $0 - memorizedResult }
]
```

此处的阶乘$x!$使用了比较无脑的方法，预先计算好结果在表示范围内的计算结果，超过表示范围则返回$-1$

最后，提供一个`performOperation`方法以供`ViewController`调用：

```swift
func performOperation (operation: String, operand: Double) -> Double? {
    if let op = operations[operation] {
        switch op {
        case .BinaryOperation(let function):
            pendingOperation = Intermediate(firstOperand: operand, waitingOperation: function)
            return nil
        case .Constant(let value):
            return value
        case .EqualOperation:
            return pendingOperation?.waitingOperation(pendingOperation!.firstOperand, operand)
        case .UnaryOperation(let function):
            return function(operand)
        case .MemoryOperation:
            switch operation {
            case "mr":
                memorizedResult = operand
            case "mc":
                memorizedResult = 0.0
            }
        }
    }
    return nil
}
```



## 项目难点





## 参考资料

- [课程slides](https://njuics.github.io/ios2021/#1)
- [实践视频](https://www.bilibili.com/video/BV1Yr4y1c7HW)
- [Apple Developer Documentation](https://developer.apple.com/documentation/)
- 一些Stackoverflow
- 一些Apple Developer Forum
- 甚至一些CSDN
