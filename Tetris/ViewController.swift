//
//  ViewController.swift
//  Tetris
//
//  Created by mxsm on 16/5/6.
//  Copyright © 2016年 mxsm. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController ,GameVIewDelegate{

    var gameView:GameView!
    
    //  定义速度和积分Label 工具条 所占宽度
    let TOOLBAR_HEIGHT:CGFloat = 44
    
    //  定义两侧边边空白的宽度
    let EDGEMARGIn_size:CGFloat = 10
    
    //  定义按钮的尺寸
    let BUTTON_size:CGFloat = 48
    //  定义按钮的透明度
    let BUTTON_alpha:CGFloat = 0.4
    //
    //  屏幕的宽和高
    var screenWith:CGFloat!
    var screenHeight:CGFloat!
    
    //  定义背景音乐的播放对象
    var backGroungMusicPlayer:AVAudioPlayer!
    
    //  定义显示目前速度的label
    var speedShow:UILabel!
    
    //  显示目前积分的label
    var scoreShow:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let screenRect = UIScreen.mainScreen().bounds
        screenWith = screenRect.width
        screenHeight = screenRect.height
        
        //  添加工具条
        self.addTopToolBar()
        
        //  创建游戏主界面
        gameView = GameView(frame:CGRectMake(screenRect.origin.x + EDGEMARGIn_size,screenRect.origin.y + TOOLBAR_HEIGHT + EDGEMARGIn_size * 2, screenRect.size.width - EDGEMARGIn_size * 2,screenRect.size.height-80))
        self.view .addSubview(gameView)
        gameView.delegate = self
        
        //  添加游戏控制旋转按钮
        self.addButtomButton()
        
        //  开始游戏
        //  获取背景音乐的URL
//        let backGroundMusicUrl  = NSBundle.mainBundle().URLForResource("", withExtension: "")
//        backGroungMusicPlayer = try? AVAudioPlayer(contentsOfURL: backGroundMusicUrl!)
//        backGroungMusicPlayer.numberOfLoops = -1
//        backGroungMusicPlayer.play()
        
        
        
       
        
    }
    
    // MARK: 创建游戏页面最上面四个显示Label
    func addTopToolBar() -> Void {
        
        let topToolBar = UIToolbar(frame:CGRectMake(0,EDGEMARGIn_size * 2,screenWith,TOOLBAR_HEIGHT))
        self.view .addSubview( topToolBar)
        
        //  速度标签
        let SpeedLabel = UILabel(frame:CGRectMake(0,0,50,TOOLBAR_HEIGHT))
        SpeedLabel.text = "速度:"
        let speedLabelItem = UIBarButtonItem(customView:SpeedLabel)
        
        //  当前速度值
        speedShow = UILabel(frame:CGRectMake(0,0,20,TOOLBAR_HEIGHT))
        speedShow.textColor = UIColor.redColor()
        let speedShowItem = UIBarButtonItem(customView:speedShow)
        
        //  积分标签
        let scoreLabel = UILabel(frame:CGRectMake(0,0,90,TOOLBAR_HEIGHT))
        scoreLabel.text = "当前积分:"
        let scoreLabelItem = UIBarButtonItem(customView:scoreLabel)
        
        // 当前积分数值
        scoreShow  =  UILabel(frame:CGRectMake(0,0,40,TOOLBAR_HEIGHT))
        scoreShow.textColor = UIColor.redColor()
        let scoreShowItem = UIBarButtonItem(customView:scoreShow)
        
        let  filxItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace,target: nil,action: nil)
        topToolBar.items = [speedLabelItem,speedShowItem,filxItem,scoreLabelItem,scoreShowItem]
        
    }
    
    // MARK: 创建控制旋转底部按钮
    func addButtomButton() -> Void{
        
        
        //  定义开始的按钮
        let startButton = UIButton.init(type: UIButtonType.Custom)
        startButton.frame=CGRectMake(screenWith - BUTTON_size * 7 - EDGEMARGIn_size,screenHeight - BUTTON_size - EDGEMARGIn_size+5, BUTTON_size * 2, BUTTON_size)
        startButton.alpha = BUTTON_alpha
        startButton.setTitle("开始", forState: UIControlState.Normal)
        startButton.backgroundColor = UIColor.purpleColor()
        startButton .addTarget(self, action:#selector(startButtonclick), forControlEvents: UIControlEvents.TouchUpInside)
        self.view .addSubview(startButton)

        
        //  定义左边的按钮
        let leftButton = UIButton.init(type: UIButtonType.Custom)
        leftButton.frame=CGRectMake(screenWith - BUTTON_size * 3 - EDGEMARGIn_size,screenHeight - BUTTON_size - EDGEMARGIn_size+5, BUTTON_size , BUTTON_size)
        leftButton.alpha = BUTTON_alpha
        leftButton.setTitle("左移", forState: UIControlState.Normal)
        leftButton.setTitleColor(UIColor.purpleColor(), forState: UIControlState.Normal)
        //leftButton.backgroundColor = UIColor.purpleColor()
        leftButton .addTarget(self, action:#selector(touchleft), forControlEvents: UIControlEvents.TouchUpInside)
        self.view .addSubview(leftButton)

        //  定义向下的按钮
        let downButton = UIButton.init(type: UIButtonType.Custom)
        downButton.frame=CGRectMake(screenWith - BUTTON_size * 2 - EDGEMARGIn_size,screenHeight - BUTTON_size - EDGEMARGIn_size+5, BUTTON_size , BUTTON_size)
        downButton.alpha = BUTTON_alpha
        //downButton.backgroundColor = UIColor.purpleColor()
        downButton.addTarget(self, action:#selector(touchdown), forControlEvents: UIControlEvents.TouchUpInside)
        self.view .addSubview(downButton)
        downButton.setTitle("向下", forState: UIControlState.Normal)
        downButton.setTitleColor(UIColor.purpleColor(), forState: UIControlState.Normal)

        
        //  定义右边的按钮
        let rightbutton = UIButton.init(type: UIButtonType.Custom)
        rightbutton.frame=CGRectMake(screenWith - BUTTON_size * 1 - EDGEMARGIn_size,screenHeight - BUTTON_size - EDGEMARGIn_size+5, BUTTON_size , BUTTON_size)
        rightbutton.alpha = BUTTON_alpha
        //rightbutton.backgroundColor = UIColor.purpleColor()
        rightbutton.addTarget(self, action:#selector(touchright), forControlEvents: UIControlEvents.TouchUpInside)
        self.view .addSubview(rightbutton)
        rightbutton.setTitle("右移", forState: UIControlState.Normal)
        rightbutton.setTitleColor(UIColor.purpleColor(), forState: UIControlState.Normal)

        
        //  定义向上的按钮
        let upbutton = UIButton.init(type: UIButtonType.Custom)
        upbutton.frame=CGRectMake(screenWith - BUTTON_size * 2 - EDGEMARGIn_size,screenHeight - BUTTON_size * 2 - EDGEMARGIn_size+5, BUTTON_size , BUTTON_size)
        upbutton.alpha = BUTTON_alpha
        //upbutton.backgroundColor = UIColor.purpleColor()
        upbutton.addTarget(self, action:#selector(touchup), forControlEvents: UIControlEvents.TouchUpInside)
        self.view .addSubview(upbutton)
        upbutton.setTitle("旋转", forState: UIControlState.Normal)
        upbutton.setTitleColor(UIColor.purpleColor(), forState: UIControlState.Normal)

        
        
    }
    
    // 开始
    func startButtonclick() -> Void {
        
        gameView.startGame()
        
    }
    // 向左
    func touchleft() -> Void {
        
        gameView.moveLeft()
    }
    // 向下
    func touchdown() -> Void {
        
        gameView.movedown()

    }
    // 右边
    func touchright() -> Void {
        
        gameView.moveRight()
        
    }
    // 向上
    func touchup() -> Void {
        
        gameView.rotate()
        
    }
    
    // MARK:三个个代理方法
    func UpdateScore(score:Int) -> Void {
        
        self.scoreShow.text = "\(score)"
        
    }
    
    func UpdateSpeed(speed:Int) -> Void {
        
        self.speedShow.text = "\(speed)"
        
    }
    
    func UpdateGameState() ->Void
    {
    
        let alview = UIAlertController.init(title: "游戏结束", message: "是否要重新开始", preferredStyle: UIAlertControllerStyle.Alert)
        
        let noAction  = UIAlertAction.init(title: "否", style: UIAlertActionStyle.Cancel, handler: { (yesaction) in
            
            print("游戏结束")
            
            
        })
        
        let  yesAction = UIAlertAction.init(title: "是", style: UIAlertActionStyle.Default, handler: { (yesAction) in
            
            print("重新开始")

            
        })
        
        alview .addAction(yesAction)
        alview .addAction(noAction)
        self .presentViewController(alview, animated: true) { 
            
        }

        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

