//
//  AppDelegate.swift
//  test
//
//  Created by Nattapong Pullkhow on 11/22/2557 BE.
//  Copyright (c) 2557 Nattapong Pullkhow. All rights reserved.
//

import Cocoa
import Foundation

class AppDelegate: NSObject, NSApplicationDelegate {
    
    //Preferences Window
    @IBOutlet var window: NSWindow
    
    @IBOutlet var MenuButtonCheck : NSButton
    @IBOutlet var nextButtunCheck : NSButton
    @IBOutlet var previousButtunCheck : NSButton
    @IBOutlet var autoStartCheck : NSButton
    @IBOutlet var VersionText : NSTextField
    
    
    @IBAction func preferencesWinClick(sender : AnyObject) {
        PreferencesWindowShow(self)
    }
    
    @IBAction func menuButtunCheckClick(sender : AnyObject) {
        var Config = config()
        var tmpStatVal = Config.AnyToBool(MenuButtonCheck.state)
        Config.setBoolKey("menubutton",Setting: tmpStatVal)
        playBarRefreshMenuItems()
    }
    
    @IBAction func nextButtunCheckClick(sender : AnyObject) {
        var Config = config()
        var tmpStatVal = Config.AnyToBool(nextButtunCheck.state)
        Config.setBoolKey("nextbutton",Setting: tmpStatVal)
        playBarRefreshMenuItems()
    }
    
    @IBAction func previousButtunCheckClick(sender : AnyObject) {
        var Config = config()
        var tmpStatVal = Config.AnyToBool(previousButtunCheck.state)
        Config.setBoolKey("previousbutton",Setting: tmpStatVal)
        playBarRefreshMenuItems()
    }
    
    @IBAction func autoStartCheckClick(sender : AnyObject) {
        var autoStart = Autostart()
        if (autoStart.getStat()) {
            autoStart.disable()
        } else {
            autoStart.enable()
        }
        
    }
    
    //About Window
    @IBOutlet var aboutWindow : NSWindow
    
    //Menu
    
    @IBOutlet var MenuBarMenu : NSMenu
    func removeWhiteSpace(string:String)->String {
        let text = string.componentsSeparatedByCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).filter({!$0.isEmpty})
        return " ".join(text)
    }
    var playBar = NSStatusBar.systemStatusBar()
    var playBarNextItem : NSStatusItem = NSStatusItem()
    var playBarPreviousItem : NSStatusItem = NSStatusItem()
    var playBarPlayItem : NSStatusItem = NSStatusItem()
    var playBarMenuItem : NSStatusItem = NSStatusItem()
    func playBarAddAllItems() {
        var Config = config()
        //Menu Buttun on MenuBar
        if (Config.getBoolKey("menubutton")) {
            playBarMenuItem = playBar.statusItemWithLength(-1)
            let iconMenu = NSImage(named: "menu")
            iconMenu.setTemplate(true)
            playBarMenuItem.image = iconMenu
            playBarMenuItem.toolTip = "Menu"
            playBarMenuItem.menu = MenuBarMenu
        }
        
        //Next Buttun on MenuBar
        if (Config.getBoolKey("nextbutton")) {
            playBarNextItem = playBar.statusItemWithLength(-1)
            let iconNext = NSImage(named: "next")
            iconNext.setTemplate(true)
            playBarNextItem.image = iconNext
            playBarNextItem.toolTip = "Play Next Track"
            playBarNextItem.action = Selector("iTunesPlayNextTrack:")
        }
        
        // Play Button on MenuBar
        
        if (iTunesPlayStat()) {
            playBarPlayItem = playBar.statusItemWithLength(-1)
            let iconPause = NSImage(named: "pause")
            iconPause.setTemplate(true)
            playBarPlayItem.image = iconPause
            playBarPlayItem.toolTip = "Pause"
            playBarPlayItem.action = Selector("iTunesPlayOrPause:")
        } else {
            playBarPlayItem = playBar.statusItemWithLength(-1)
            let iconPlay = NSImage(named: "play")
            iconPlay.setTemplate(true)
            playBarPlayItem.image = iconPlay
            playBarPlayItem.toolTip = "Play"
            playBarPlayItem.action = Selector("iTunesPlayOrPause:")
        }
        
        // Previous Button on MenuBar
        
        if (Config.getBoolKey("previousbutton")) {
            playBarPreviousItem = playBar.statusItemWithLength(-1)
            let iconPrevious = NSImage(named: "previous")
            iconPrevious.setTemplate(true)
            playBarPreviousItem.image = iconPrevious
            playBarPreviousItem.toolTip = "Play Previous Track"
            playBarPreviousItem.action = Selector("iTunesPlayPreviousTrack:")
        }
        playBarSetTimer()
    }
    
    func playBarClearMenuItems() {
        playBar.removeStatusItem(playBarMenuItem)
        playBar.removeStatusItem(playBarPlayItem)
        playBar.removeStatusItem(playBarNextItem)
        playBar.removeStatusItem(playBarPreviousItem)
    }
    func playBarRefreshMenuItems() {
        playBarClearMenuItems()
        playBarAddAllItems()
    }
    func playBarSetPuase() {
        let iconPause = NSImage(named: "pause")
        iconPause.setTemplate(true)
        playBarPlayItem.toolTip = "Pause"
        playBarPlayItem.image = iconPause
    }
    func playBarSetPlay() {
        let iconPlay = NSImage(named: "play")
        iconPlay.setTemplate(true)
        playBarPlayItem.toolTip = "Play"
        playBarPlayItem.image = iconPlay
    }
    func playBarSetTimer() {
        var playBarTimer = NSTimer.scheduledTimerWithTimeInterval(3, target: self, selector: "playBarPlaySwitchPuase:", userInfo: nil, repeats: true)
    }
    func playBarPlaySwitchPuase(sender : AnyObject) {
        iTunesPlayStat() ? playBarSetPuase() : playBarSetPlay()
    }
    
    //PlayBack Func
    func iTunesPlayStat() -> Bool {
        let OSAArgs:Array = ["-e","tell application \"System Events\"","-e"," if not (exists application process \"iTunes\") then","-e"," set iTunestat to \"stop\"","-e"," else","-e"," tell application \"iTunes\"","-e"," set iTunestat to player state as string","-e"," end tell","-e"," end if","-e"," end tell","-e","iTunestat"]
        var _iTuneTask = NSTask()
        _iTuneTask.launchPath = "/usr/bin/osascript"
        _iTuneTask.arguments = OSAArgs
        
        let _pipe = NSPipe()
        _iTuneTask.standardOutput = _pipe
        _iTuneTask.launch()
        
        let data = _pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = removeWhiteSpace(NSString(data: data,encoding: NSUTF8StringEncoding))
        
        if (output == "playing") {
            return true
        } else {
            return false
        }
    }
    func iTunesPlayNextTrack(sender : AnyObject) {
        let OSAArgs:Array = ["-e","on init()", "-e" , "try", "-e" , "tell application \"System Events\"", "-e" , "if not (exists application process \"iTunes\") then", "-e" , "tell application \"iTunes\" to activate", "-e" , "delay 2", "-e" , "init()", "-e" , "else", "-e" , "tell application \"iTunes\"", "-e" , "tell application \"iTunes\" to play (next track)", "-e" , "end tell", "-e" , "end if", "-e" , "end tell", "-e" , "end try", "-e" , "end init", "-e" , "init()"]
        var _iTuneTask = NSTask()
        _iTuneTask.launchPath = "/usr/bin/osascript"
        _iTuneTask.arguments = OSAArgs
        _iTuneTask.launch()
        playBarSetPuase()
    }
    func iTunesPlayPreviousTrack(sender : AnyObject) {
        let OSAArgs:Array = ["-e","on init()", "-e","try", "-e","tell application \"System Events\"", "-e","if not (exists application process \"iTunes\") then", "-e","tell application \"iTunes\" to activate", "-e","delay 2", "-e","init()", "-e","else", "-e","tell application \"iTunes\"", "-e","tell application \"iTunes\" to play (previous track)", "-e","end tell", "-e","end if", "-e","end tell", "-e","end try", "-e","end init", "-e","init()"]
        var _iTuneTask = NSTask()
        _iTuneTask.launchPath = "/usr/bin/osascript"
        _iTuneTask.arguments = OSAArgs
        _iTuneTask.launch()
        playBarSetPuase()
    }
    func iTunesPlayOrPause(sender : AnyObject) {
        let OSAArgs:Array = ["-e","tell application \"System Events\"","-e","if not (exists application process \"iTunes\") then","-e","tell application \"iTunes\" to activate","-e","else","-e","tell application \"iTunes\"","-e","set iTunesStat to player state as string","-e","if iTunesStat is not \"playing\" then","-e","tell application \"iTunes\" to play","-e","set iTunesStat to player state as string","-e","else","-e","tell application \"iTunes\" to pause","-e","set iTunesStat to player state as string","-e","end if","-e","end tell","-e","end if","-e","end tell","-e","iTunesStat"]
        var _iTuneTask = NSTask()
        _iTuneTask.launchPath = "/usr/bin/osascript"
        _iTuneTask.arguments = OSAArgs
        
        let _pipe = NSPipe()
        _iTuneTask.standardOutput = _pipe
        _iTuneTask.launch()
        
        let data = _pipe.fileHandleForReading.readDataToEndOfFile()
        let output: String = removeWhiteSpace(NSString(data: data,encoding: NSUTF8StringEncoding))
        if (output == "playing") {
            playBarSetPuase()
        } else {
            playBarSetPlay()
        }

    }
    
    // FirstRun
    
    class SystemHelper {
        let appPath:String = NSBundle.mainBundle().bundlePath
        let ApllicationsiPlayPath:String = "/Applications/iPlay.app"
        let homeDirectoryPath:String = NSHomeDirectory()
        var FManager = NSFileManager.defaultManager()
        
        func onStartUp() {
            var Config = config()
            if (Config.getBoolKey("firstrun") || appPath != ApllicationsiPlayPath) {
                firstRun()
            }
        }
        func firstRun() {
            var Config = config()
            if (appPath != ApllicationsiPlayPath) {
                if (FManager.fileExistsAtPath( ApllicationsiPlayPath )) {
                    FManager.removeItemAtPath( ApllicationsiPlayPath , error: nil)
                }
                FManager.copyItemAtPath(appPath, toPath: ApllicationsiPlayPath, error: nil)
                if (FManager.fileExistsAtPath( ApllicationsiPlayPath )) {
                    var iPlayTask = NSTask()
                    iPlayTask.launchPath = "/usr/bin/open"
                    iPlayTask.arguments = [ApllicationsiPlayPath]
                    iPlayTask.launch()
                    NSApplication.sharedApplication().terminate(self)
                }
            } else {
                Config.setBoolKey("firstrun",Setting: false)
                var appDelGate = AppDelegate()
                appDelGate.PreferencesWindowShow(self)
            }
        }
        func setQuit() {
            NSApplication.sharedApplication().terminate(self)
        }
        
        func setRestart() {
            var iPlayTask = NSTask()
            iPlayTask.launchPath = "/usr/bin/open"
            iPlayTask.arguments = [appPath]
            iPlayTask.launch()
            NSApplication.sharedApplication().terminate(self)
        }
        /*
        func toggleDockIcon(state:Bool) ->Bool {
            var transState: ProcessApplicationTransformState
            if (state) {
                transState =  ProcessApplicationTransformState(kProcessTransformToForegroundApplication)
            } else {
                transState =  ProcessApplicationTransformState(kProcessTransformToBackgroundApplication)
            }
            var psn = ProcessSerialNumber(highLongOfPSN: 0, lowLongOfPSN: UInt32(kCurrentProcess))
            let transStatus: OSStatus = TransformProcessType(&psn, transState)
            return transState == 0
        }
        func toggleDockIcon(state:Bool) ->Bool {
            if (state) {
                return NSApp.setActivationPolicy(NSApplicationActivationPolicy.Regular)
            } else {
                return NSApp.setActivationPolicy(NSApplicationActivationPolicy.Accessory)
            }
        }
        var systemHelper = SystemHelper()
        systemHelper.toggleDockIcon(true)
        */
    }
    // Auto Start Func
    
    class Autostart {
        let LaunchAgentsPath:String = NSHomeDirectory() + "/Library/LaunchAgents/"
        var autoStartFilePath:String { return LaunchAgentsPath +  "NattapongPullkhow.iPlay.AutoStart.plist" }
        var OriginAutostartFile:String { return NSBundle.mainBundle().pathForResource("NattapongPullkhow.iPlay.AutoStart", ofType: "plist") }
        var FManager = NSFileManager.defaultManager()
        
        func enable() {
            // Logic Check File & Folder Exists
            
            if (!FManager.fileExistsAtPath( LaunchAgentsPath )) {
                FManager.createDirectoryAtPath(LaunchAgentsPath, attributes: nil)
            }
            if (!FManager.fileExistsAtPath( autoStartFilePath )) {
                FManager.copyItemAtPath(OriginAutostartFile, toPath: autoStartFilePath, error: nil)
            }
        }
        func getStat() ->Bool {
            let FManager = NSFileManager.defaultManager()
            if (FManager.fileExistsAtPath( LaunchAgentsPath ) && FManager.fileExistsAtPath( autoStartFilePath )) {
                return true
            } else {
                return false
            }
        }
        
        func disable() {
            let FManager = NSFileManager.defaultManager()
            if (FManager.fileExistsAtPath( LaunchAgentsPath ) && FManager.fileExistsAtPath( autoStartFilePath )) {
                FManager.removeItemAtPath( autoStartFilePath , error: nil)
            }
            
        }
    }
    
    // Plist Func
    class config {
        var UserFolderPath:NSString { return NSHomeDirectory() + "/Library/Application Support/iPlay/" }
        var UserFilePath:NSString { return "\(UserFolderPath)config.plist" }
        var OriginFilePath:NSString { return NSBundle.mainBundle().pathForResource("config", ofType: "plist") }
        var FManager = NSFileManager.defaultManager()
        var FilePath:NSString {
        if (ExistsConfigFile()) {
            return self.UserFilePath
        } else {
            return self.OriginFilePath
            }
        }
        
        func ExistsConfigFile() ->Bool {
            if (self.FManager.fileExistsAtPath( self.UserFolderPath ) && self.FManager.fileExistsAtPath( self.UserFilePath )) {
                return true
            } else {
                if (!self.FManager.fileExistsAtPath( self.UserFolderPath )) {
                    self.FManager.createDirectoryAtPath(self.UserFolderPath, attributes: nil)
                }
                
                if (!self.FManager.fileExistsAtPath( self.UserFilePath )) {
                    self.FManager.copyItemAtPath(self.OriginFilePath, toPath: self.UserFilePath, error: nil)
                }
                if (self.FManager.fileExistsAtPath( self.UserFolderPath ) && self.FManager.fileExistsAtPath( self.UserFilePath )) {
                    return true
                } else {
                    return false
                }
            }
        }
        
        func listKey() ->NSMutableDictionary {
            var dict = NSMutableDictionary()
            if(ExistsConfigFile()) {
                var allConfigKey:Dictionary = NSDictionary(contentsOfFile: self.FilePath)
                for (key_,val_ : AnyObject) in allConfigKey {
                    dict.setValue(val_, forKey: "\(key_)")
                }
            }
            return dict
        }
        
        func getKey(ConfigKey:NSString) ->AnyObject{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return val_
                }
            }
            return 1
        }
        func getIntKey(ConfigKey:NSString) ->Int{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return AnyToInt(val_)
                }
            }
            return 1
        }
        func getStrKey(ConfigKey:NSString) ->String{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return AnyToString(val_)
                }
            }
            return "1"
        }
        func getBoolKey(ConfigKey:NSString) ->Bool{
            var all_ = NSMutableDictionary(contentsOfFile: self.FilePath)
            for (key_ : AnyObject ,val_ : AnyObject) in all_ {
                if ("\(ConfigKey)" == "\(key_)") {
                    return AnyToBool(val_)
                }
            }
            return false
        }
        
        func setKey(ConfigKey:String,Setting:Int) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue(Setting, forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func setIntKey(ConfigKey:String,Setting:Int) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue(Setting, forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func setStrKey(ConfigKey:String,Setting:String) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue("\(Setting)", forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func setBoolKey(ConfigKey:String,Setting:Bool) {
            if (!ConfigKey.isEmpty && Setting != nil && ExistsConfigFile()) {
                var DicAllConfigKey = listKey()
                DicAllConfigKey.setValue(Setting, forKey: "\(ConfigKey)")
                DicAllConfigKey.writeToFile(FilePath, atomically: true)
            }
        }
        func AnyToString(Object_:AnyObject)->String {
            var tmpVal : NSObject = Object_ as NSObject
            var tmpObject_:String = "\(tmpVal)"
            return "\(tmpObject_)"
        }
        func AnyToInt(Object_:AnyObject)->Int {
            var tmpVal : NSObject = Object_ as NSObject
            var tmpObject_:String = "\(tmpVal)"
            var tmpObjectInt_:Int = tmpObject_.toInt()!
            return tmpObjectInt_
        }
        func AnyToBool(Object_:AnyObject)->Bool {
            var tmpVal : NSObject = Object_ as NSObject
            var tmpObject_:String = "\(tmpVal)"
            if (tmpObject_ == "true" || tmpObject_ == "1") {
                return true
            }
            return false
        }
    }

    // System Function
    override func awakeFromNib() {
        playBarAddAllItems()
        
    }
    func applicationDidFinishLaunching(aNotification: NSNotification?) {
        var systemHelper = SystemHelper()
        systemHelper.onStartUp()
    }
    
    
    
    @IBAction func setQuitiPlay(sender : AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }

    @IBAction func AboutWinMenuBar(sender : AnyObject) {
        AboutWindowShow(self)
    }
    @IBAction func PreferencesWindowShow(sender : AnyObject) {
        if(!window.visible) {
            var Config = config()
            var autoStart = Autostart()
            //Menu Buttun
            if (Config.getBoolKey("menubutton")) {
                MenuButtonCheck.state = 1
            } else {
                MenuButtonCheck.state = 0
            }
            
            //Next Buttun
            if (Config.getBoolKey("nextbutton")) {
                nextButtunCheck.state  = 1
            } else {
                nextButtunCheck.state  = 0
            }
            
            // Previous Button
            if (Config.getBoolKey("previousbutton")) {
                previousButtunCheck.state = 1
            } else {
                previousButtunCheck.state = 0
            }
            // Auto Start
            if (autoStart.getStat()) {
                autoStartCheck.state = 1
            } else {
                autoStartCheck.state = 0
            }
            window.orderFront(window)
        }
    }
    
    @IBAction func AboutWindowShow(sender : AnyObject) {
        if(!aboutWindow.visible) {
            aboutWindow.orderFront(aboutWindow)
            VersionText.stringValue = "Version \(Version.Main()) build \(Version.Build())"
        }
    }
    class Version {
        class func Main()->String {
            let version: AnyObject? = NSBundle.mainBundle().infoDictionary["CFBundleShortVersionString"]
            return version as String
        }
        class func Build()->String {
            let build: AnyObject? = NSBundle.mainBundle().infoDictionary["CFBundleVersion"]
            return build as String
        }
    }
    
    func applicationWillTerminate(aNotification: NSNotification?) {
        playBarClearMenuItems()
    }
    
}

