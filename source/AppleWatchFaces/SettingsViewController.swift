//
//  ViewController.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 10/17/18.
//  Copyright © 2018 Michael Hill. All rights reserved.
//

import UIKit
import SpriteKit

class SettingsViewController: UIViewController, WatchSessionManagerDelegate {

    @IBOutlet var optionsTableContainer: UIView!
    @IBOutlet var layerTableContainer: UIView!
    @IBOutlet var colorsTableContainer: UIView!
    
    @IBOutlet var addNewColorButton: UIButton!
    
    @IBOutlet var undoButton: UIBarButtonItem!
    @IBOutlet var redoButton: UIBarButtonItem!
    @IBOutlet var sendSettingButton: UIButton!
    
    @IBOutlet var nudgeLButton: UIButton!
    @IBOutlet var nudgeRButton: UIButton!
    @IBOutlet var nudgeUButton: UIButton!
    @IBOutlet var nudgeDButton: UIButton!
    
    @IBOutlet var posXLabel: UILabel!
    @IBOutlet var posYLabel: UILabel!
    @IBOutlet var numControlsView: UIView!
    
    @IBOutlet var alphaLessButton: UIButton!
    @IBOutlet var alphaMoreButton: UIButton!
    
    @IBOutlet var alphaLabel: UILabel!
    @IBOutlet var alphaControlsView: UIView!
    
    @IBOutlet var scaleLessButton: UIButton!
    @IBOutlet var scaleMoreButton: UIButton!
    
    @IBOutlet var scaleLabel: UILabel!
    @IBOutlet var scaleControlsView: UIView!
    
    @IBOutlet var angleLessButton: UIButton!
    @IBOutlet var angleMoreButton: UIButton!
    
    @IBOutlet var angleLabel: UILabel!
    @IBOutlet var angleControlsView: UIView!
    
    @IBOutlet var addNewLayerButton: UIButton!
    
    @IBOutlet var groupSegmentControl: UISegmentedControl!
    @IBOutlet var timeTravelView: UIView!

    weak var watchPreviewViewController:WatchPreviewViewController?
    weak var faceLayersTableViewController:FaceLayersTableViewController?
    weak var faceColorsTableViewController:FaceColorsTableViewController?
    weak var faceOptionsTableViewController:FaceOptionsTableViewController?
    
    static var currentFaceSetting: FaceSetting = FaceSetting.defaults()
    var currentFaceIndex = 0
    static var undoArray = [FaceSetting]()
    static var redoArray = [FaceSetting]()
    var buttonRepeatTimer = Timer()
    
    //values for re-usable UIActionSheets
    static var actionsTitle:String = ""
    static var actionsArray = [String]()
    static var actionCell:AnyObject = FaceLayerTableViewCell()
    static var actionCellMedthodName = "someMethod"
    static var actionCellItemChosen = 0
    
    static let settingsChangedNotificationName = Notification.Name("settingsChanged")
    static let settingsGetCameraImageNotificationName = Notification.Name("getBackgroundImageFromCamera")
    static let settingsPreviewSwipedNotificationName = Notification.Name("swipedOnPreview")
    static let settingsExitingNotificationName = Notification.Name("settingsExiting")
    static let settingsCallActionSheet = Notification.Name("settingsCallActionSheet")
    
    func longPressAction(gesture: UILongPressGestureRecognizer, sender: UIButton) {
        if gesture.state == .began {
            //debugPrint("long press start")
            buttonRepeatTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                //debugPrint("Timer fired!")
                if sender == self.alphaLessButton || sender == self.alphaMoreButton {
                    self.adjustAlphaForLayerItem(sender: sender)
                }
                if sender == self.nudgeUButton || sender == self.nudgeDButton || sender == self.nudgeLButton || sender == self.nudgeRButton {
                    self.nudgeLayerItem(sender: sender)
                }
                if sender == self.angleLessButton || sender == self.angleMoreButton {
                    self.adjustAngleForLayerItem(sender: sender)
                }
                if sender == self.scaleLessButton || sender == self.scaleMoreButton {
                    self.adjustScaleForLayerItem(sender: sender)
                }
            }
        }
        if gesture.state == .ended || gesture.state == .cancelled || gesture.state == .failed {
            //debugPrint("long press end")
            buttonRepeatTimer.invalidate()
        }
    }
    
    @IBAction func respondToLongPressGestureAlphaLess(gesture: UILongPressGestureRecognizer) {
        longPressAction(gesture: gesture, sender: alphaLessButton)
    }
    
    @IBAction func respondToLongPressGestureAlphaMore(gesture: UILongPressGestureRecognizer) {
        longPressAction(gesture: gesture, sender: alphaMoreButton)
    }
    
    @IBAction func respondToLongPressGesturePositionUp(gesture: UILongPressGestureRecognizer) {
        longPressAction(gesture: gesture, sender: nudgeUButton)
    }
    
    @IBAction func respondToLongPressGesturePositionDown(gesture: UILongPressGestureRecognizer) {
        longPressAction(gesture: gesture, sender: nudgeDButton)
    }
    
    @IBAction func respondToLongPressGesturePositionLeft(gesture: UILongPressGestureRecognizer) {
        longPressAction(gesture: gesture, sender: nudgeLButton)
    }
    
    @IBAction func respondToLongPressGesturePositionRight(gesture: UILongPressGestureRecognizer) {
        longPressAction(gesture: gesture, sender: nudgeRButton)
    }
    
    @IBAction func respondToLongPressGestureAngleLess(gesture: UILongPressGestureRecognizer) {
        longPressAction(gesture: gesture, sender: angleLessButton)
    }
    
    @IBAction func respondToLongPressGestureAngleMore(gesture: UILongPressGestureRecognizer) {
        longPressAction(gesture: gesture, sender: angleMoreButton)
    }
    
    @IBAction func respondToLongPressGestureSizeLess(gesture: UILongPressGestureRecognizer) {
        longPressAction(gesture: gesture, sender: scaleLessButton)
    }
    
    @IBAction func respondToLongPressGestureSizeMore(gesture: UILongPressGestureRecognizer) {
        longPressAction(gesture: gesture, sender: scaleMoreButton)
    }
    
    
    
    @IBAction func respondToPanGesture(gesture: UIPanGestureRecognizer) {
        //forward time travel hangler
        if let watchPreviewViewController = watchPreviewViewController {
            watchPreviewViewController.respondToPanGesture(gesture: gesture)
        }
    }
    
    @IBAction func adjustAngleForLayerItem( sender: UIButton) {
        
        var scaleAdjust:CGFloat = 0.0
        let nudgeAmt:CGFloat = AppUISettings.layerSettingsAngleIncrement
        
        if sender == angleLessButton { scaleAdjust = -nudgeAmt }
        if sender == angleMoreButton { scaleAdjust = nudgeAmt }
        
        if let flTVC = faceLayersTableViewController {
            flTVC.adjustLayerItem(adjustmentType: .Angle, amount: scaleAdjust)
        }
    }
    
    @IBAction func adjustScaleForLayerItem( sender: UIButton) {
        
        var scaleAdjust:CGFloat = 0.0
        let nudgeAmt = CGFloat(AppUISettings.layerSettingsScaleIncrement)
        
        if sender == scaleLessButton { scaleAdjust = -nudgeAmt }
        if sender == scaleMoreButton { scaleAdjust = nudgeAmt }
        
        if let flTVC = faceLayersTableViewController {
            flTVC.adjustLayerItem(adjustmentType: .Scale, amount: scaleAdjust)
        }
    }
    
    @IBAction func adjustAlphaForLayerItem( sender: UIButton) {
        
        var alphaAdjust:CGFloat = 0.0
        let nudgeAmt = CGFloat(AppUISettings.layerSettingsAlphaIncrement)
        
        if sender == alphaLessButton { alphaAdjust = -nudgeAmt }
        if sender == alphaMoreButton { alphaAdjust = nudgeAmt }
        
        if let flTVC = faceLayersTableViewController {
            flTVC.adjustLayerItem(adjustmentType: .Alpha, amount: alphaAdjust)
        }
    }
    
    @IBAction func nudgeLayerItem( sender: UIButton) {
        //TODO: set direction and turn on timer
        var xDirection:CGFloat = 0
        var yDirection:CGFloat = 0
        
        let nudgeAmt = CGFloat(AppUISettings.layerSettingsPositionIncrement)
        
        if sender == nudgeLButton { xDirection = -nudgeAmt }
        if sender == nudgeRButton { xDirection = nudgeAmt }
        if sender == nudgeUButton { yDirection = nudgeAmt }
        if sender == nudgeDButton { yDirection = -nudgeAmt }
        
        if let flTVC = faceLayersTableViewController {
            flTVC.nudgeItem(xDirection: xDirection, yDirection: yDirection, absoluteX: 0, absoluteY: 0)
        }
    }
    
    func highlightLayer( index: Int) {
        if watchPreviewViewController != nil {
            watchPreviewViewController?.highlightLayer(index: index)
        }
    }
    
    @IBAction func newColor() {
        let newColor = "#FFFFFFFF"
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        setUndoRedoButtonStatus()
        
        SettingsViewController.currentFaceSetting.faceColors.append(newColor)
        
        if let fcVC = faceColorsTableViewController {
            fcVC.addNewItem()
        }
    }
    
    func addNewItem( layerType: FaceLayerTypes) {
        //TODO: copy some things from last item for convenience
        
        var faceLayerOptions = FaceLayerOptions()
        switch layerType {
        case .BatteryIndicator:
            faceLayerOptions = BatteryIndicatorOptions.init(defaults: true)
        case .Gear:
            faceLayerOptions = GearLayerOptions.init(defaults: true)
        case .ShapeRing:
            faceLayerOptions = ShapeLayerOptions.init(defaults: true)
        case .NumberRing:
            faceLayerOptions = NumberRingLayerOptions.init(defaults: true)
        case .DateTimeLabel:
            faceLayerOptions = DigitalTimeLayerOptions.init(defaults: true)
        case .GradientTexture:
            faceLayerOptions = GradientBackgroundLayerOptions.init(defaults: true)
        case .SecondHand:
            faceLayerOptions = SecondHandLayerOptions.init(defaults: true)
        case .MinuteHand:
            faceLayerOptions = MinuteHandLayerOptions.init(defaults: true)
        case .HourHand:
            faceLayerOptions = HourHandLayerOptions.init(defaults: true)
        case .ImageTexture:
            faceLayerOptions = ImageBackgroundLayerOptions.init(defaults: true)
        case .ColorTexture:
            faceLayerOptions = ImageBackgroundLayerOptions.init(defaults: true)
        case .ParticleField:
            faceLayerOptions = ParticleFieldLayerOptions.init(defaults: true)
        //default:
        //    faceLayerOptions = FaceLayerOptions()
        }
        
        let newLayer = FaceLayer.init(layerType: layerType, alpha: 1.0, horizontalPosition: 0, verticalPosition:0, scale: 1.0,
                                      angleOffset: 0, desiredThemeColorIndex: 0, layerOptions: faceLayerOptions, filenameForImage: "")
        
        //add to undo stack for actions to be able to undo
        SettingsViewController.addToUndoStack()
        setUndoRedoButtonStatus()
        
        SettingsViewController.currentFaceSetting.faceLayers.append(newLayer)
        
        let newLayerNum = SettingsViewController.currentFaceSetting.faceLayers.count - 1
        redrawForNewLayer(newLayer: newLayer, layerNum: newLayerNum)
    }
    
    func duplicateLayer( layerNumber: Int) {
        let faceLayer = SettingsViewController.currentFaceSetting.faceLayers[layerNumber]
        if let newLayer = faceLayer.clone() {
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()
            setUndoRedoButtonStatus()
            
            SettingsViewController.currentFaceSetting.faceLayers.insert(newLayer, at: layerNumber+1)
            
            redrawForNewLayer(newLayer: newLayer, layerNum: layerNumber+1)
        }
    }
    
    func redrawForNewLayer(newLayer: FaceLayer, layerNum: Int) {
        redrawPreviewClock()
        
        //turn on layer controls in case this is the first layer
        drawUIForSelectedLayer(selectedLayer: layerNum, section: .All)
        showLayerControls()
        
        if let flVC = faceLayersTableViewController {
            flVC.addNewItem(layerNum: layerNum)
        }
    }
    
    @IBAction func newItem() {
        let optionMenu = UIAlertController(title: nil, message: "New Item", preferredStyle: .actionSheet)
        
        optionMenu.view.tintColor = UIColor.black
        
        for layerType in FaceLayerTypes.userSelectableValues {
            let newActionDescription = FaceLayer.descriptionForType(layerType)
            let newAction = UIAlertAction(title: newActionDescription, style: .default, handler: { action in
                self.addNewItem(layerType: layerType)
            } )
            optionMenu.addAction(newAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(cancelAction)
        
        
        //dark mode hack
        if #available(iOS 13, *) {
            if self.traitCollection.userInterfaceStyle == .dark {
                    optionMenu.view.tintColor = UIColor.white
            }
        }
        
        self.present(optionMenu, animated: true, completion: nil)

        //move layers table to the bottom to better handle inserts
        if let faceLayersTableViewController = faceLayersTableViewController, SettingsViewController.currentFaceSetting.faceLayers.count>0 {
                let indexPathBottom = IndexPath(row: SettingsViewController.currentFaceSetting.faceLayers.count-1, section: 0)
                faceLayersTableViewController.tableView.scrollToRow(at: indexPathBottom, at: UITableView.ScrollPosition.bottom, animated: true)
                faceLayersTableViewController.tableView.beginUpdates()
                faceLayersTableViewController.tableView.endUpdates()
        }
    }
    
    @objc func onNotificationForSettingsChanged(notification:Notification) {
        //debugPrint("onNotificationForSettingsChanged called")
        
        redrawPreviewClock()
        setUndoRedoButtonStatus()
    }
    
    @objc func onNotificationForGetCameraImage(notification:Notification) {
        guard let data = notification.userInfo as? [String: Int] else { return }
        guard let layerIndex = data["layerIndex"] else { return }
        
        CameraHandler.shared.imagePickedBlock = { (image, url) in
            //add to undo stack for actions to be able to undo
            SettingsViewController.addToUndoStack()

            /* get your image here */
            let optimalSize = AppUISettings.getOptimalImageSize()
            let resizedImage = AppUISettings.imageWithImage(image: image, fitToSize: optimalSize)

            var fileName = ""
            if url != nil {
                // gallery image
                
                // save it to the docs folder with name of the filename
                fileName =  url!.lastPathComponent
            } else {
                //camera image no URL
                
                fileName = SettingsViewController.currentFaceSetting.uniqueID + ".jpg"
            }
            debugPrint("got an image! filename: " + fileName + " original: " + image.description + " resized: " + resizedImage.description)

            if let layerOptions = SettingsViewController.currentFaceSetting.faceLayers[layerIndex].layerOptions as? ImageBackgroundLayerOptions {
                
                //grab file extension for determining if we should set transparency
                if url != nil {
                    let pathExtention = url!.pathExtension
                    if pathExtention.uppercased() == "PNG" {
                        layerOptions.hasTransparency = true
                    } else {
                        layerOptions.hasTransparency = false
                    }
                }
            
                //only save original if its larger, otherwise we can use thumb
                if image.size.width > resizedImage.size.width && image.size.height > resizedImage.size.height {
                    //save original
                    debugPrint("** saved an original for export **")
                    _ = image.saveImported(imageName: fileName)
                }
                
                //save resized for use in the app ( but maybe not sharing )
                _ = resizedImage.save(imageName: fileName, usePNG: layerOptions.hasTransparency)
            
                //_ = resizedImage.save(imageName: fileName)
                SettingsViewController.currentFaceSetting.faceLayers[layerIndex].filenameForImage = fileName
            
                layerOptions.backgroundType = .FaceBackgroundTypeFilled
                
                NotificationCenter.default.post(name: SettingsViewController.settingsChangedNotificationName, object: nil, userInfo:nil)
                NotificationCenter.default.post(name: FaceLayersTableViewController.reloadLayerNotificationName, object: nil, userInfo:["layerIndex":layerIndex])
            }

            
        }
        
        CameraHandler.shared.showActionSheet(vc: self)
    }
    
    @objc func onNotificationForPreviewSwiped(notification:Notification) {
        
        if let userInfo = notification.userInfo as? [String: String] {
            if userInfo["action"] == "sendSetting" {
                sendSettingAction()
            }
        }
    }
    
    @objc func onNotificationForCallActionSheet(notification:Notification) {
        
        func showSettingsAlert( title: String, alertActions: [UIAlertAction]) {
            let optionMenu = UIAlertController(title: nil, message: title, preferredStyle: .actionSheet)
            optionMenu.view.tintColor = UIColor.black
            
            for action in alertActions {
                optionMenu.addAction(action)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            optionMenu.addAction(cancelAction)
            
            //dark mode hack
            if #available(iOS 13, *) {
                if self.traitCollection.userInterfaceStyle == .dark {
                        optionMenu.view.tintColor = UIColor.white
                }
            }
            
            self.present(optionMenu, animated: true, completion: nil)
        }
        
        var actions:[UIAlertAction] = []
        
        for (index,actionString) in SettingsViewController.actionsArray.enumerated() {
            let newAction = UIAlertAction(title: actionString, style: .default, handler: { action in
                if let cell = SettingsViewController.actionCell as? FaceLayerTableViewCell {
                    cell.returnFromAction( actionName: SettingsViewController.actionCellMedthodName, itemChosen: index)
                }
            } )
            actions.append(newAction)
        }
        showSettingsAlert( title: SettingsViewController.actionsTitle, alertActions: actions )
    }
    
    
    func redrawPreviewClock() {
        //tell preview to reload
        if watchPreviewViewController != nil {
            watchPreviewViewController?.redraw()
            //self.showMessage( message: SettingsViewController.currentClockSetting.title)
        }
    }
    
    func redrawSettingsTable() {
        if let faceOptionsTableViewController = faceOptionsTableViewController {
            faceOptionsTableViewController.reload()
        }
        if let faceLayersTableViewController = faceLayersTableViewController {
            faceLayersTableViewController.reload()
        }
        if let faceColorsTableViewController = faceColorsTableViewController {
            faceColorsTableViewController.reload()
        }
    }
    
    func isLayersSelected()->Bool {
        return (!layerTableContainer.isHidden)
    }
    
    @IBAction func groupChangeAction(sender: UISegmentedControl) {
        //show / hide the tableViews
        
        var highlightColor = SKColor.init(hexString: AppUISettings.settingHighlightColor)
        
        if sender.selectedSegmentIndex == 0 { //main
            hideLayerControls()
            
            colorsTableContainer.isHidden = true
            layerTableContainer.isHidden = true
            optionsTableContainer.isHidden = false
            
            addNewLayerButton.isHidden = true
            addNewColorButton.isHidden = true
            
            highlightColor = SKColor.init(hexString: "#3A9FBF")
        }
        if sender.selectedSegmentIndex == 1 { // layers
            colorsTableContainer.isHidden = true
            optionsTableContainer.isHidden = true
            layerTableContainer.isHidden = false
            
            addNewLayerButton.isHidden = false
            addNewColorButton.isHidden = true
            
            // reload layers because colors and other things may have changes
            if let faceLayersTableViewController = faceLayersTableViewController {
                faceLayersTableViewController.reload()
            }
            
            highlightColor = SKColor.orange
        }
        if sender.selectedSegmentIndex == 2 { // colors
            hideLayerControls()
            
            colorsTableContainer.isHidden = false
            layerTableContainer.isHidden = true
            optionsTableContainer.isHidden = true
            
            addNewLayerButton.isHidden = true
            addNewColorButton.isHidden = false
            
            highlightColor = SKColor.init(hexString: AppUISettings.settingHighlightColor)
        }
        
        groupSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: highlightColor
            ], for: .selected)
    }
    
    //MARK: ** draw UI **
    
    func hideLayerControls() {
        guard self.numControlsView.isHidden==false else { return }
        
        for controlsView in [numControlsView, alphaControlsView, scaleControlsView,
                             angleControlsView] {
            let controlsView = controlsView!
            controlsView.alpha = 1.0
            UIView.animate(withDuration: 0.25, animations: {
                controlsView.alpha = 0.0
            }) { (Bool) in
                controlsView.isHidden = true
            }
        }
    }
    
    func showLayerControls() {
        guard self.numControlsView.isHidden==true else { return }
        
        for controlsView in [numControlsView, alphaControlsView, scaleControlsView,
                     angleControlsView] {
                        let controlsView = controlsView!
                        controlsView.isHidden = false
                        controlsView.alpha = 0.0
                        
                        UIView.animate(withDuration: 0.25) {
                            controlsView.alpha = 1.0
                        }
        }
        
    }
    
    func drawUIForSelectedLayer(selectedLayer: Int, section: WatchFaceNode.LayerAdjustmentType) {
        let faceLayer = SettingsViewController.currentFaceSetting.faceLayers[selectedLayer]
        
        if (section == .All) {
            showLayerControls()
        }
        
        if (section == .Scale || section == .All) {
            scaleLabel.text = String(round(faceLayer.scale*1000)/1000)
        }
        
        if (section == .Angle || section == .All) {
            angleLabel.text = String(round(faceLayer.angleOffset*1000)/1000)
        }
        
        if (section == .Alpha || section == .All) {
            alphaLabel.text = String(round(faceLayer.alpha*1000)/1000)
        }
        
        if (section == .Position || section == .All) {
            posXLabel.text = String(round(faceLayer.horizontalPosition*100)/100)
            posYLabel.text = String(round(faceLayer.verticalPosition*100)/100)
        }
    }
    
    func sizeFromPreviewView( scale: CGFloat, reload: Bool) {
        if let faceLayersTableViewController = faceLayersTableViewController {
            faceLayersTableViewController.sizeFromPreviewView(scale: scale, reload: reload)
        }
    }
    
    func dragOnPreviewView( absoluteX: CGFloat, absoluteY: CGFloat, reload: Bool) {
        if let faceLayersTableViewController = faceLayersTableViewController {
            faceLayersTableViewController.dragOnPreviewView(absoluteX: absoluteX, absoluteY: absoluteY, reload: reload)
        }
    }
    /////////////////
    
    @IBAction func cloneClockSettings() {
        //add a new item into the shared settings
        let oldTitle = SettingsViewController.currentFaceSetting.title
        let newClockSetting = SettingsViewController.currentFaceSetting.clone(keepUniqueID: false)!
        newClockSetting.title = oldTitle + " copy"
        UserFaceSetting.sharedFaceSettings.insert(newClockSetting, at: currentFaceIndex)
        UserFaceSetting.saveToFile()
        
        SettingsViewController.currentFaceSetting = newClockSetting
        redrawPreviewClock() //show correct clock
        redrawSettingsTable() //show new title
        clearUndoAndUpdateButtons()
        
        showError(errorMessage: "Face copied")
        
        //tell chooser view to reload its cells
        NotificationCenter.default.post(name: FaceChooserViewController.faceChooserReloadChangeNotificationName, object: nil, userInfo:nil)
    }
    
    @IBAction func nextClock() {
        currentFaceIndex = currentFaceIndex + 1
        if (UserFaceSetting.sharedFaceSettings.count <= currentFaceIndex) {
            currentFaceIndex = 0
        }
        
        SettingsViewController.currentFaceSetting = UserFaceSetting.sharedFaceSettings[currentFaceIndex].clone()!
        redrawPreviewClock()
        redrawSettingsTable()
        clearUndoAndUpdateButtons()
    }
    
    @IBAction func prevClock() {
        currentFaceIndex = currentFaceIndex - 1
        if (currentFaceIndex<0) {
            currentFaceIndex = UserFaceSetting.sharedFaceSettings.count - 1
        }
        
        SettingsViewController.currentFaceSetting = UserFaceSetting.sharedFaceSettings[currentFaceIndex].clone()!
        redrawPreviewClock()
        redrawSettingsTable()
        clearUndoAndUpdateButtons()
    }
    
    @IBAction func saveClock() {
        //just save this clock
        UserFaceSetting.sharedFaceSettings[currentFaceIndex] = SettingsViewController.currentFaceSetting
        UserFaceSetting.saveToFile() //remove this to reset to defaults each time app loads
        self.showMessage( message: SettingsViewController.currentFaceSetting.title + " saved.")
        
        //makeThumb(fileName: SettingsViewController.currentClockSetting.uniqueID)
    }
    
    //MARK: UIViewController
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        
        if parent == nil {
            if let vc = self.navigationController?.viewControllers.first as? FaceChooserViewController {
                vc.faceListReloadType = .onlyvisible
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        if segue.destination is WatchPreviewViewController {
            let vc = segue.destination as? WatchPreviewViewController
            watchPreviewViewController = vc
            vc?.settingsViewController = self
        }
        if segue.destination is FaceLayersTableViewController {
            let vc = segue.destination as? FaceLayersTableViewController
            faceLayersTableViewController = vc
            vc?.settingsViewController = self
        }
        if segue.destination is FaceColorsTableViewController {
            let vc = segue.destination as? FaceColorsTableViewController
            faceColorsTableViewController = vc
            vc?.settingsViewController = self
        }
        if segue.destination is FaceOptionsTableViewController {
            let vc = segue.destination as? FaceOptionsTableViewController
            faceOptionsTableViewController = vc
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if (self.isMovingFromParent) {
            // moving back, if anything has changed, lets save
            if SettingsViewController.undoArray.count>0 {
                saveClock()
                _ = UIImage.delete(imageName: SettingsViewController.currentFaceSetting.uniqueID + ".jpg")
                NotificationCenter.default.post(name: SettingsViewController.settingsExitingNotificationName, object: nil, userInfo:["currentFaceIndex":currentFaceIndex])
            }
        }
        
        //TODO: probably not needed
        //force clean up memory
        if let scene = watchPreviewViewController?.skView.scene as? SKWatchScene {
            scene.cleanup()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get current selected clock
        redrawSettingsTable()
        redrawPreviewClock()
        
        setUndoRedoButtonStatus()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //was killing all buttons along the left side
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        
        WatchSessionManager.sharedManager.delegate = self
        SettingsViewController.clearUndoStack()
        
        colorsTableContainer.isHidden = true
        addNewColorButton.isHidden = true
        optionsTableContainer.isHidden = true
        
        numControlsView.layer.cornerRadius = AppUISettings.watchControlsCornerRadius
        numControlsView.layer.borderWidth = AppUISettings.watchControlsWidth
        numControlsView.layer.borderColor = AppUISettings.watchControlsBorderColor
        
        alphaControlsView.layer.cornerRadius = AppUISettings.watchControlsCornerRadius
        alphaControlsView.layer.borderWidth = AppUISettings.watchControlsWidth
        alphaControlsView.layer.borderColor = AppUISettings.watchControlsBorderColor
        
        scaleControlsView.layer.cornerRadius = AppUISettings.watchControlsCornerRadius
        scaleControlsView.layer.borderWidth = AppUISettings.watchControlsWidth
        scaleControlsView.layer.borderColor = AppUISettings.watchControlsBorderColor
        
        angleControlsView.layer.cornerRadius = AppUISettings.watchControlsCornerRadius
        angleControlsView.layer.borderWidth = AppUISettings.watchControlsWidth
        angleControlsView.layer.borderColor = AppUISettings.watchControlsBorderColor
        
        timeTravelView.layer.cornerRadius = 6.0
        timeTravelView.layer.borderWidth = AppUISettings.watchControlsWidth
        timeTravelView.layer.borderColor = AppUISettings.watchFrameBorderColor
        
        //style the section segment
        // Add lines below selectedSegmentIndex
        groupSegmentControl.backgroundColor = .clear
        groupSegmentControl.tintColor = .clear
        
        // Add lines below the segmented control's tintColor
        groupSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: SKColor.white
            ], for: .normal)
        
        groupSegmentControl.setTitleTextAttributes([
            NSAttributedString.Key.font : UIFont(name: "DINCondensed-Bold", size: 20)!,
            NSAttributedString.Key.foregroundColor: SKColor.init(hexString: AppUISettings.settingHighlightColor)
            ], for: .selected)
        
        SettingsViewController.currentFaceSetting = UserFaceSetting.sharedFaceSettings[currentFaceIndex].clone()!
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForPreviewSwiped(notification:)), name: SettingsViewController.settingsPreviewSwipedNotificationName, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForSettingsChanged(notification:)), name: SettingsViewController.settingsChangedNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForGetCameraImage(notification:)), name: SettingsViewController.settingsGetCameraImageNotificationName, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(onNotificationForCallActionSheet(notification:)), name: SettingsViewController.settingsCallActionSheet, object: nil)
    }
    
}

