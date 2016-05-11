//
//  GameView.swift
//  Tetris
//
//  Created by mxsm on 16/5/6.
//  Copyright © 2016年 mxsm. All rights reserved.
//

import UIKit
import AVFoundation

protocol GameVIewDelegate {

    func UpdateScore(score:Int)
    func UpdateSpeed(speed:Int)
    func UpdateGameState()
    
}

struct Block {
    
    var X:Int
    var Y:Int
    var Color:Int
    var description:String {
        
        return "Block[X=\(X),Y=\(Y),Color=\(Color)]"
    }
}

class GameView: UIView {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var delegate:GameVIewDelegate!
    
    
    let TETRIS_Row  = 22
    let TETRIS_Cols = 15
    let CELL_Size:Int
    
    // 当前积分
    var curScore:Int = 0
    
    // 基本速度
    let BASE_Speed = 1.0
    
    // 当前速度
    var curSpeed:Int = 0
    
    // 计时器
    var curTimer:NSTimer?
    
    // 定义绘制网格的线的粗细
    let  STROKE_Width:Int = 1
    var  CTX:CGContextRef!
   
    //
    let  NO_Block = 0
    
    // 定义一个UIimage实例，该实例代表内存中的图片
    var image:UIImage!
    
    // 定义一个消除音乐的播放对象
    var disBackGroundMusicPlayer:AVAudioPlayer!

    // 定义用于纪录俄罗斯方块的二维数组的属性
    var tetris_status = [[Int]]()
    
    // MARK初始化游戏状态
    func initTetrisStatus() -> Void {
        
        let tmpRow = Array.init(count: TETRIS_Cols, repeatedValue: NO_Block)
        tetris_status  = Array.init(count: TETRIS_Row, repeatedValue: tmpRow)
        
    }
    
    // 定义方块的颜色
    let colors = [UIColor.whiteColor().CGColor,UIColor.blackColor().CGColor,UIColor.purpleColor().CGColor,UIColor.blueColor().CGColor,UIColor.yellowColor().CGColor,UIColor.brownColor().CGColor,UIColor.magentaColor().CGColor]
    
    // 定义几种可能出现的方块组合
    var blockArr = [[Block]]()
    
    // 定义纪录 “正在下掉的四个方块” 位置
    var currentFall = [Block]()
    func initBlock() -> Void {
        
        // 生成一个在 0 - blockArr.count  之间的随机数
        let rand =  Int(arc4random()) % blockArr.count
        // 随机取出 blockArr 数组中的某个元素为正在下掉的方块组合
        currentFall = blockArr[rand]

    }
    
    
    // MARK: 重写初始化方法
    override init(frame: CGRect) {
      
        // 初始化几种可能的组合方块
        self.blockArr = [
          
            // 第一种可能出现的组合 Z
            [
                Block(X:TETRIS_Cols/2 - 1,Y:0,Color:1),
                Block(X:TETRIS_Cols/2,Y:0,Color:1),
                Block(X:TETRIS_Cols/2,Y:1,Color:1),
                Block(X:TETRIS_Cols/2 + 1,Y:1,Color:1)
            
            ],
            // 第二种可能出现的组合 反Z
            [
                Block(X:TETRIS_Cols/2 + 1,Y:0,Color:2),
                Block(X:TETRIS_Cols/2,Y:0,Color:2),
                Block(X:TETRIS_Cols/2,Y:1,Color:2),
                Block(X:TETRIS_Cols/2 - 1,Y:1,Color:2)
                
            ],
            // 第三种可能出现的组合 田
            [
                Block(X:TETRIS_Cols/2 - 1,Y:0,Color:3),
                Block(X:TETRIS_Cols/2,Y:0,Color:3),
                Block(X:TETRIS_Cols/2 - 1,Y:1,Color:3),
                Block(X:TETRIS_Cols/2 ,Y:1,Color:3)
                    
            ],
            // 第四种可能出现的组合 L
            [
                Block(X:TETRIS_Cols/2 - 1,Y:0,Color:4),
                Block(X:TETRIS_Cols/2 - 1,Y:1,Color:4),
                Block(X:TETRIS_Cols/2 - 1,Y:2,Color:4),
                Block(X:TETRIS_Cols/2 ,Y:2,Color:4)
                    
            ],
            // 第五种可能出现的组合 J
            [
                Block(X:TETRIS_Cols/2,Y:0,Color:5),
                Block(X:TETRIS_Cols/2,Y:1,Color:5),
                Block(X:TETRIS_Cols/2,Y:2,Color:5),
                Block(X:TETRIS_Cols/2 - 1,Y:2,Color:5)
                    
            ],
            // 第六种可能出现的组合 ——
            [
                Block(X:TETRIS_Cols/2,Y:0,Color:6),
                Block(X:TETRIS_Cols/2,Y:1,Color:6),
                Block(X:TETRIS_Cols/2,Y:2,Color:6),
                Block(X:TETRIS_Cols/2,Y:3,Color:6)
                
            ],
            // 第七种可能出现的组合 土缺一
            [
                Block(X:TETRIS_Cols/2,Y:0,Color:7),
                Block(X:TETRIS_Cols/2-1,Y:1,Color:7),
                Block(X:TETRIS_Cols/2,Y:1,Color:7),
                Block(X:TETRIS_Cols/2 + 1,Y:1,Color:7)
                    
            ],
        ]
        
    
     // 计算俄罗斯方块的大小
        self.CELL_Size =  Int(frame.size.width) / TETRIS_Cols
        super.init(frame: frame)
        
        // 消除的方块的音频文件URL
        //let disMusicUrl = NSBundle.mainBundle().URLForResource("", withExtension: "")
        // 创建播放对象
        //disBackGroundMusicPlayer  = try? AVAudioPlayer(contentsOfURL: disMusicUrl!)
        //disBackGroundMusicPlayer.numberOfLoops = 0
        
        // 开启内存中的绘图
        UIGraphicsBeginImageContext(self.bounds.size)
        
        // 获取 Quartz 2D的绘图的 CGContextRef 对象
        CTX =  UIGraphicsGetCurrentContext()
        
        // 填充背景色
        CGContextSetFillColorWithColor(CTX, UIColor.whiteColor().CGColor)
        CGContextFillRect(CTX, self.bounds)
        
        // 绘制俄罗斯方块的网格
        creatcells(TETRIS_Row, cols: TETRIS_Cols, cellwidth: CELL_Size, cellHeight: CELL_Size)
        //
        image = UIGraphicsGetImageFromCurrentImageContext()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: 绘制俄罗斯方库网格的方法
    func creatcells(rows:Int,cols:Int,cellwidth:Int,cellHeight:Int) -> Void {
        
        // 开始创建路径
        CGContextBeginPath(CTX)
        // 绘制横向网格对应的路径
        for  i  in 0...TETRIS_Row {
            
            CGContextMoveToPoint(CTX, 0, CGFloat(i  *  CELL_Size))
            CGContextAddLineToPoint(CTX, CGFloat(TETRIS_Cols * CELL_Size), CGFloat(i * CELL_Size))
            
        }
        
        // 绘制纵向的网格对应路径
        for  i  in 0...TETRIS_Cols {
            
            CGContextMoveToPoint(CTX, CGFloat(i  *  CELL_Size),0)
            CGContextAddLineToPoint(CTX, CGFloat(i * CELL_Size), CGFloat(TETRIS_Row * CELL_Size))
            
        }
        // 关闭
        CGContextClosePath(CTX)
        
        // 设置笔触颜色
        CGContextSetStrokeColorWithColor(CTX, UIColor(red: 0.9 , green: 0.9 , blue: 0.9,alpha: 1).CGColor)
        // 设置效线条粗细
        CGContextSetLineWidth(CTX, CGFloat(STROKE_Width))
        // 绘制线条
        CGContextStrokePath(CTX)
        
    }
    
    // 重写 drawRect 方法
    override func drawRect(rect: CGRect) {

        //
        UIGraphicsGetCurrentContext()
        // 将内存中的image图像绘制在该组件的左上角
        image.drawAtPoint(CGPointZero)
        
    }
    
    // MARK:开始游戏
    func startGame()
    {
        
        self.curSpeed = 1
        self.delegate.UpdateSpeed(self.curSpeed)
        
        self.curScore = 0
        self.delegate.UpdateScore(self.curScore)
        
        // 初始化游戏状态
        self.initTetrisStatus()
        
        // 初始化四个正在下落的方块
        self.initBlock()
        
        // 定时器控制下落
        curTimer = NSTimer.scheduledTimerWithTimeInterval(BASE_Speed/Double(curSpeed), target: self, selector: #selector(self.movedown), userInfo: nil, repeats: true)
        
        
    }
    
    
    
    // MARK:控制方块组合向下移动
    func movedown () -> Void {
        
        // 定义能否向下掉落的 标签
        var canDown = true
        
        // 遍历每一块方块，判断它是否能向下掉落
        for i in 0..<currentFall.count {
            
            // 第一种情况，如果位置到行数最底下了，不能再下落
            if currentFall[i].Y >= TETRIS_Row - 1 {
                
                canDown = false
                break
            }
            // 第二种情况，如果他的下面有了方块，不能再下落
            if tetris_status[currentFall[i].Y + 1][currentFall[i].X] != NO_Block {
                
                canDown = false
                break
            }
            
        }
        // 如果能向下掉落
        if canDown {
    
            self.drawBlock()//
            
            for i in 0..<currentFall.count {
                
                let cur = currentFall[i]
                // 设置填充颜色
                CGContextSetFillColorWithColor(CTX, UIColor.whiteColor().CGColor)
                
                CGContextFillRect(CTX, CGRectMake(CGFloat(cur.X * CELL_Size + STROKE_Width), CGFloat(cur.Y * CELL_Size + STROKE_Width), CGFloat(CELL_Size - STROKE_Width * 2),CGFloat(CELL_Size - STROKE_Width * 2)))
                

            }
            //  遍历每一个方块。控制每一个方块的 有坐标都 加 1
            for i in 0..<currentFall.count {
        
                currentFall[i].Y += 1
                
            }
            //  将下移后的每一个方块的背景涂色称该方块的颜色
            for i in 0..<currentFall.count {
        
                let cur = currentFall[i]
                // print(cur.X   ,   cur.Y)
                CGContextSetFillColorWithColor(CTX, colors[cur.Color])
                CGContextFillRect(CTX, CGRectMake(CGFloat(cur.X * CELL_Size + STROKE_Width), CGFloat(cur.Y * CELL_Size + STROKE_Width), CGFloat(CELL_Size - STROKE_Width * 2),CGFloat(CELL_Size - STROKE_Width * 2)))
                
            }
            
        }
        // 不能向下掉落
        else
        {
            // 遍历每个方块，把每个方块的值纪录到
            for i in 0..<currentFall.count {
                
                let cur = currentFall[i]
                // 小于2表示已经到最上面，游戏要结束了
                if cur.Y < 2 {
                    
                    // 计时器失效
                    curTimer?.invalidate()
                    // 提示游戏结束
                    self.delegate.UpdateGameState()
                    
                }
                
                // 把每个方块当前所在的位置赋值为当前方块的颜色值
                tetris_status[cur.Y][cur.X] = cur .Color
                
        }
            // 判断是否有可消除的行
            lineFull()
            // 开始一组新的方块
            initBlock()
    }
    
    // 获取缓存区的图片
    image = UIGraphicsGetImageFromCurrentImageContext()
    // 通知重绘
    self.setNeedsDisplay()

    }

    // MARK: 判断是否有一行已满
    func lineFull() -> Void{
      // 遍历每一行
        for i in 0..<TETRIS_Row {
            
            var flag = true
            // 遍历每一行的每一个单元
            for j in 0..<TETRIS_Cols {
                
                if tetris_status[i][j] == NO_Block {
                    
                    flag = false
                    break
                }
            }
            // 如果当前行已经全部有了方块
            if flag {
                
                // 当前积分增加 100
                curScore += 100
                // 代理更新当前积分
                self.delegate.UpdateScore(curScore)
                
                if curScore >= curSpeed * curSpeed * 500{
                    
                    curSpeed += 1
                    // 代理更新当前速度
                    self.delegate.UpdateSpeed(curSpeed)
                    curTimer?.invalidate()
                    curTimer = NSTimer.scheduledTimerWithTimeInterval(BASE_Speed/Double(curSpeed), target: self, selector: #selector(self.movedown), userInfo: nil, repeats: true)
                }
                
            }
            // 把所有的整体下移一行
            for var j = i; j < 0 ; j -= 1 {
                
                for k in 0..<TETRIS_Cols {
                    
                    tetris_status[j][k] = tetris_status[j-1][k]
                    
                }
                
            }
            // 播放消除的音乐
//            if !disBackGroundMusicPlayer.play() {
//                
//                disBackGroundMusicPlayer.play()
//            }
        }
    }
    
    //MARK: 绘制俄罗斯方块的状态
    func drawBlock() -> Void {
        
        for i in 0..<TETRIS_Row {
            
            for j in 0..<TETRIS_Cols {
                
                if tetris_status[i][j] != NO_Block {
                    
                    // 设置填充颜色
                    CGContextSetFillColorWithColor(CTX, colors[tetris_status[i][j]])
                    CGContextFillRect(CTX, CGRectMake(CGFloat(j * CELL_Size + STROKE_Width),CGFloat(i * CELL_Size + STROKE_Width) , CGFloat(CELL_Size - STROKE_Width * 2), CGFloat(CELL_Size - STROKE_Width * 2)))
                    
                }
                else
                {
                
                    // 设置填充颜色
                    CGContextSetFillColorWithColor(CTX, UIColor.whiteColor().CGColor)
                    CGContextFillRect(CTX, CGRectMake(CGFloat(j * CELL_Size + STROKE_Width),CGFloat(i * CELL_Size + STROKE_Width) , CGFloat(CELL_Size - STROKE_Width * 2), CGFloat(CELL_Size - STROKE_Width * 2)))
                    
                }
            }
        }
    }
    
    //MARK: 定义左边移动的方法
    func moveLeft () -> Void {
        
        // 定义左边移动的标签
        var canLeft = true
        for i in 0..<currentFall.count {
            
            if currentFall[i].X <= 0 {
                
                canLeft = false
                break
            }
            // 左变位置的前边一块
            if tetris_status[currentFall[i].Y][currentFall[i].X - 1] != NO_Block  {
                
                canLeft = false
                break
                
            }
        }
        // 如果可以左移
        if canLeft {
            
            self.drawBlock()
            // 将左移前的的每一个方块背景涂成白底
            for i in 0..<currentFall.count {
                
                let  cur = currentFall[i]
                CGContextSetFillColorWithColor(CTX, UIColor.whiteColor()
                .CGColor)
                CGContextFillRect(CTX, CGRectMake(CGFloat(cur.X * CELL_Size + STROKE_Width), CGFloat(cur.Y * CELL_Size + STROKE_Width), CGFloat(CELL_Size - STROKE_Width * 2), CGFloat(CELL_Size - STROKE_Width * 2)))
                
            }
            
            // 左移正字啊下掉的方块
            for i in 0..<currentFall.count {
                
                currentFall[i].X -= 1
                
            }
            
            // 将左移后的的每一个方块背景涂成对应的颜色
            for i in 0..<currentFall.count {
                
                let  cur = currentFall[i]
                CGContextSetFillColorWithColor(CTX,colors[cur.Color])
                CGContextFillRect(CTX, CGRectMake(CGFloat(cur.X * CELL_Size + STROKE_Width), CGFloat(cur.Y * CELL_Size + STROKE_Width), CGFloat(CELL_Size - STROKE_Width * 2), CGFloat(CELL_Size - STROKE_Width * 2)))
                
            }
            // 获取缓冲区的图片
            image = UIGraphicsGetImageFromCurrentImageContext()

            // 通知重新绘制
            self.setNeedsDisplay()
       
        }
    }
    
    // MARK: 定义右边移动的方法
    func moveRight () -> Void {
        
        // 能否右移动的标签
        var canRight = true
        for i in 0..<currentFall.count {
            
            // 如果已经到最右边就不能再移动
            if currentFall[i].X >= TETRIS_Cols - 1 {
                
                canRight = false
                break
            }
            // 如果右边有方块，就不能再移动
            if tetris_status[currentFall[i].Y][currentFall[i].X + 1] != NO_Block {
                
                canRight = false
                break
            }
        }
        // 如果能右边移动
        if canRight {
            
            self.drawBlock()
            // 将香油移动的每个方块涂白色
            for i in 0..<currentFall.count {
                
                let cur = currentFall[i]
                CGContextSetFillColorWithColor(CTX, UIColor.whiteColor().CGColor)
                CGContextFillRect(CTX, CGRectMake(CGFloat(cur.X * CELL_Size + STROKE_Width), CGFloat(cur.Y * CELL_Size + STROKE_Width), CGFloat(CELL_Size - STROKE_Width * 2), CGFloat(CELL_Size - STROKE_Width * 2)))
                
            }
        }
        // 右边移动正在下落的所有的方块
        for i in 0..<currentFall.count {
            
            currentFall[i].X += 1
            
        }
        // 有以后将每个方块的颜色背景图成各自方块对应的颜色
        for i in 0..<currentFall.count {
            
            let  cur = currentFall[i]
            // 设置填充颜色
            CGContextSetFillColorWithColor(CTX, colors[cur.Color])
            // 绘制矩形
            CGContextFillRect(CTX, CGRectMake(CGFloat(cur.X * CELL_Size + STROKE_Width), CGFloat(cur.Y * CELL_Size + STROKE_Width), CGFloat(CELL_Size - STROKE_Width * 2), CGFloat(CELL_Size - STROKE_Width * 2)))
            
            image = UIGraphicsGetImageFromCurrentImageContext()
            // 通知重新绘制
            self.setNeedsDisplay()
            
        }
    }
    
    // MARK: 定义旋转的方法
    func rotate () -> Void {
     
       // 定义是否能旋转的标签
        var canRotate = true
        for i in 0..<currentFall.count
        {
            
            let preX = currentFall[i].X
            let preY = currentFall[i].Y
            // 始终以第三块作为旋转的中心
            // 当 i == 2的时候，说明是旋转的中心
            if i != 2
            {
                
                // 计算方块旋转后的X，Y坐标
                let afterRotateX  =  currentFall[2].X + preY - currentFall[2].Y
                let afterRotateY  =  currentFall[2].Y + currentFall[2].X - preX

                // 如果旋转后的x,y坐标越界，或者旋转后的位置已有别的方块，表示不能旋转
                if afterRotateX < 0 || afterRotateX > TETRIS_Cols - 1 || afterRotateY < 0 || afterRotateY > TETRIS_Row - 1 || tetris_status[afterRotateY][afterRotateX] != NO_Block
                {
                    
                    canRotate = false
                    break
                    
                }
            }
            
        }
        
        // 如果能旋转
        if canRotate
        {
                
                self.drawBlock()
                
                for i in 0..<currentFall.count
                {
                    
                    let  cur = currentFall[i]
                    // 设置填充颜色
                    CGContextSetFillColorWithColor(CTX, UIColor.whiteColor().CGColor)
                    // 绘制矩形
                    CGContextFillRect(CTX, CGRectMake(CGFloat(cur.X * CELL_Size + STROKE_Width), CGFloat(cur.Y * CELL_Size + STROKE_Width), CGFloat(CELL_Size - STROKE_Width * 2), CGFloat(CELL_Size - STROKE_Width * 2)))
                    
                }
                
                for i in 0..<currentFall.count
                {
                    
                    let preX = currentFall[i].X
                    let preY = currentFall[i].Y
                    
                    // 始终第三个作为旋转中心
                    if i != 2
                    {
                        
                        currentFall[i].X = currentFall[2].X + preY - currentFall[2].Y
                        currentFall[i].Y = currentFall[2].Y + currentFall[2].X - preX
                        
                    }
                    
                }
            
                for i in 0..<currentFall.count
                {
                    
                    let cur = currentFall[i]
                    CGContextSetFillColorWithColor(CTX, colors[cur.Color])
                    // 绘制矩形
                    CGContextFillRect(CTX, CGRectMake(CGFloat(cur.X * CELL_Size + STROKE_Width), CGFloat(cur.Y * CELL_Size + STROKE_Width), CGFloat(CELL_Size - STROKE_Width * 2), CGFloat(CELL_Size - STROKE_Width * 2)))
                    
                }
                
                // 获取缓存区的图片
                image = UIGraphicsGetImageFromCurrentImageContext()
                // 通知重新绘制
                self.setNeedsDisplay()
                
            }
        
    }
    
}