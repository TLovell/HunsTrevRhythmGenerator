//
//  ViewController.swift
//  Beat Generator
//
//  Created by Trevor Lovell on 10/7/15.
//  Copyright (c) 2015 Trevor Lovell. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var theOutput: UILabel!
    @IBOutlet weak var beatValue: UILabel!
    @IBOutlet weak var countOffLabel: UILabel!
    @IBOutlet weak var tapArea: UIImageView!
    @IBOutlet weak var theButtonOutlet: UIButton!
    @IBOutlet weak var subdivisionLabel: UILabel!
    @IBOutlet weak var tempoLabel: UILabel!
    @IBOutlet weak var evaluationLabel: UILabel!
    @IBOutlet weak var theTryAgainOutlet: UIButton!
    @IBOutlet weak var theLevelLabel: UILabel!
    @IBOutlet weak var theIntensityLabel: UILabel!
    @IBOutlet weak var theRandomizeOutlet: UIButton!
    @IBOutlet weak var beatStepperOutlet: UIStepper!
    @IBOutlet weak var subStepperOutlet: UIStepper!
    @IBOutlet weak var tempoStepperOutlet: UIStepper!
    @IBOutlet weak var levelStepperOutlet: UIStepper!
    @IBOutlet weak var intensityStepperOutlet: UIStepper!
    @IBOutlet weak var metronomeOutlet: UIImageView!
    @IBOutlet weak var beatIndicator: UIImageView!
    @IBOutlet weak var numeraterOutlet: UILabel!
    @IBOutlet weak var denominatorOutlet: UILabel!
    
    var beatCount = 4
    var subDivision = 2
    var beatCollection : [String] = []
    var generatedBeat : [Int] = []
    var generatedString : [String] = []
    var startTime = NSTimeInterval()
    var time = NSTimer()
    var timeoff = NSTimer()
    var timeoffput = NSTimer()
    var timeoffputcounter = 0
    var currentBeat : Int = 0
    var exerciseRunning = false
    var recordedTaps : [NSTimeInterval] = []
    var timeAtStart : NSTimeInterval = 0.0
    var timeTapped : NSTimeInterval = 0.0
    var tempoValue = 120
    var timeStep : Double = 0
    var answer : [NSTimeInterval] = []
    var rightTouches = 0
    var wrongTouches = 0
    var answerDraft : [NSTimeInterval] = []
    var level = 1 
    var intensity = 0.5
    var noteLengths : [Int] = []
    var restLengths : [Int] = []
    var beatTypeToggle : [Int] = []
    var lengthMaster : [Int] = []
    var typeMaster : [Int] = []
    var tempoCount = 0
    var metronomeColor = 0
    var imageNames : [String] = []
    var arrayOfImages: [UIImageView] = []
    
//    let sub1lev1 = [1, 0]
//    
//    let sub2lev1 = [10, 11]
//    let sub2lev2 = [01]
//    
//    let sub3lev1 = [100, 111, 000]
//    let sub3lev2 = [101, 110]
//    let sub3lev3 = [011, 001, 010]
//    
//    let sub4lev1 = [1000, 1010, 1111]
//    let sub4lev2 = [1110, 1011]
//    let sub4lev3 = [1101, 1100, 1001, 0010, 0011]
//    let sub4lev4 = [0111, 0110, 0101, 0100, 0001]
    
    let beatSources : [String: [String]] = ["11": ["1", "0"], "12": ["1", "0"], "13": ["1", "0"], "14": ["1", "0"], 
        "21" : ["10", "11", "00"], "22" : ["01"], "23" : ["01"], "24" : ["01"],
        "31" : ["100", "111", "000"], "32": ["101", "110"], "33" : ["011", "001", "010"], "34" : ["011", "001", "010"],
        "41" : ["1000", "1010", "1111"], "42" : ["1110", "1011"], "43" : ["1101", "1100", "1001", "0010", "0011"], "44" : ["0111", "0110", "0101", "0100", "0001"]]
    
    @IBAction func theStepper(sender: UIStepper) {
        beatCount = Int(sender.value)
        beatValue.text = String(Int(sender.value))
        theTryAgainOutlet.enabled = false
    }
    
    @IBAction func theSubStepper(sender: UIStepper) {
        subDivision = Int(sender.value)
        subdivisionLabel.text = String(Int(sender.value))
        theTryAgainOutlet.enabled = false
    }
    
    @IBAction func theTempoStepper(sender: UIStepper) {
        tempoValue = Int(sender.value)
        tempoLabel.text = String(Int(sender.value))
        theTryAgainOutlet.enabled = false
    }
    
    @IBAction func theLevelStepper(sender: UIStepper) {
        level = Int(sender.value)
        theLevelLabel.text = String(Int(sender.value))
        theTryAgainOutlet.enabled = false
    }
    
    @IBAction func theIntensityStepper(sender: UIStepper) {
        intensity = Double(sender.value)
        theIntensityLabel.text = "\(Double(sender.value))"
        theTryAgainOutlet.enabled = false
    }
    
    func enableButtons() {
        theButtonOutlet.enabled = true
        theTryAgainOutlet.enabled = true
        theRandomizeOutlet.enabled = true
    }
    
    func tempo() {
        metronomeOutlet.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)
        metronomeColor = 240
        tempoCount += 1
        if tempoCount == (beatCount + 1) {
            tempoCount = 1
        }
        countOffLabel.text = String(tempoCount)
        switch currentBeat {
        case 3:
            countOffLabel.text = "Ready!"
        case 2:
            countOffLabel.text = "Go!"
            exerciseRunning = true
            startTime = NSDate.timeIntervalSinceReferenceDate()
        case (1-beatCount):
            currentBeat = 0
            countOffLabel.text = ""
            time.invalidate()
            timeoff.invalidate()
            timeoffput.invalidate()
            enableButtons()
            exerciseRunning = false
            metronomeOutlet.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
            //print(recordedTaps)
            checkAnswer()
        default:
            break;
        }
        currentBeat -= 1
    }
    
    func tempoOffPut() {
        metronomeColor -= 4
        metronomeOutlet.backgroundColor = UIColor(red: CGFloat(metronomeColor)/255, green: CGFloat(metronomeColor)/255, blue: CGFloat(metronomeColor)/255, alpha: 1.0)
    }
    
    func checkTap(tapTime : Double) {
        var onBeat = false
        for note in answerDraft {
            let difference = tapTime - note
            if difference > -0.1 && difference < 0.2 && onBeat == false {
                onBeat = true
                answerDraft.removeAtIndex(answerDraft.indexOf(note)!)
            }
        }
//        print(onBeat)
//        print(tapTime)
        if onBeat == true {
//            tapArea.backgroundColor = UIColor.greenColor()
            rightTouches += 1
        } else {
            wrongTouches += 1
//            tapArea.backgroundColor = UIColor.redColor()
        }
    }
    
    func randomGenerate() {
        var beatLevelAssignment : [Int] = []
        for _ in 1...beatCount { //Procedurally generates an array of integers that represent the "Level" value of each beat in the exercise, which will all be less than the level Variable.
            var rng : Int
            if level == 1 {
                beatLevelAssignment.append(1)
            } else {
                rng = Int(arc4random_uniform(UInt32(level - 1))) + 1
                beatLevelAssignment.append(rng)
            }
        }
        var currentLevelCount = 0
        var density : Double = Double(currentLevelCount) / Double(beatCount)
        while density <= intensity { //Decides how many current level beats will be overwritten into the exercise based on the intensity variable
            currentLevelCount += 1
            density = Double(currentLevelCount)/Double(beatCount)
        }
        currentLevelCount -= 1
//        var currentLevelCount = Int(intensity * 10.0 * Double(beatCount)) - (Int(intensity * 10.0 * Double(beatCount)) % 10)
        if currentLevelCount > 0 {
            var currentLevelPlacement : [Int] = []
            for _ in 1...currentLevelCount { //Decides where in the exercise these current level beats will be placed
                var rng : Int = Int(arc4random_uniform(UInt32(beatCount)))
                while (currentLevelPlacement.filter { $0 == rng }).count > 0 {
                    rng = Int(arc4random_uniform(UInt32(beatCount)))
                }
                currentLevelPlacement.append(rng)
            }
            for placement in currentLevelPlacement { //overwrites the beat assignments decided in the first loop with current level beats
                beatLevelAssignment.removeAtIndex(placement)
                beatLevelAssignment.insert(level, atIndex: placement)
            }
        }
        //print(beatLevelAssignment)
        for levelAssignment in beatLevelAssignment { //Creates the index necessary to use the dictionary "beatSources", then selects one of the returned arrays of beat values at random and appends it to an array of strings: beatCollection.
            let sourceIndex : String = "\(subDivision)\(levelAssignment)"
            if beatSources[sourceIndex] != nil {
                let arraySource = beatSources[sourceIndex]!
                let rng = Int(arc4random_uniform(UInt32(arraySource.count)))
                beatCollection.append(arraySource[rng])
            } else {
                var i = levelAssignment
                var sampleIndex : String = "\(subDivision)\(levelAssignment)"
                while beatSources[sampleIndex] == nil {
                    i -= 1
                    sampleIndex = "\(subDivision)\(levelAssignment)"
                }
                let arraySource = beatSources[sampleIndex]!
                let rng = Int(arc4random_uniform(UInt32(arraySource.count)))
                beatCollection.append(arraySource[rng])
            }
        }
        //print(beatCollection)
        var combinedString : String = ""
        for beat in beatCollection {
            combinedString += beat
        }
        generatedString = combinedString.characters.map { String($0) }
        var stringIndex = 0
        var previousString : String = ""
        for string in generatedString { //Changes some of the 0s in the generated exercise to 2s (only if its preceeded by a 1 or 2)
            if (previousString == "1" || previousString == "2") && string == "0" {
                let rng = arc4random_uniform(2)
                if rng == 1 {
                    generatedString.removeAtIndex(stringIndex)
                    generatedString.insert("2", atIndex: stringIndex)
                    previousString = "2"
                } else {
                    previousString = "0"
                }
            } else {
                previousString = string
            }
            stringIndex += 1
        }
        for string in generatedString { // Outputs the generatedBeat array
            generatedBeat.append(Int(string)!)
        }
        //print(generatedString)
        //print(generatedBeat)
        for count in 1...(beatCount-1) { //adds spaces in the string output for readability
            let reverseCount = beatCount - count
            generatedString.insert(" ", atIndex: (reverseCount * subDivision))
        }
    }
    
    func areaTouched() {
        if exerciseRunning == true {
            let currentTime = NSDate.timeIntervalSinceReferenceDate()
            recordedTaps.append(currentTime - startTime)
            checkTap(currentTime - startTime)
        }
    }
    
    func areaReleased() {
//        tapArea.backgroundColor = UIColor.blueColor()
    }
    
    func getAnswer() {
        if !generatedBeat.isEmpty {
            var i = 1 * subDivision
            for beat in generatedBeat {
                if beat == 1 {
                    answer.append(Double(i) * timeStep)
                }
                i += 1
            }
            //print(answer)
            answerDraft = answer
        }
    }

    func checkAnswer() {
        if rightTouches == answer.count && wrongTouches == 0 {
            print("Correct Answer!")
            evaluationLabel.text = "Correct!"
        } else {
            print("Wrong Answer...")
            evaluationLabel.text = "Wrong..."
        }
    }
    
    func exerciseOutput() {
        var previousInt = "3"
        var lengthNote = 0
        var lengthRest = 0
        lengthMaster = []
        noteLengths = []
        restLengths = []
        beatTypeToggle = []
        for string in generatedString {
            var initiate = false
            if string != " " {
                if (string == "0" && previousInt != "0") || string == "1" {
                    initiate = true
                }
                if initiate == true {
                    if previousInt == "0" {
                        restLengths.append(lengthRest)
                        beatTypeToggle.append(0)
                    } else if previousInt != "3" {
                        noteLengths.append(lengthNote)
                        beatTypeToggle.append(1)
                    }
                    if string == "0" {
                        lengthRest = 1
                    } else { lengthNote = 1 }
                } else {
                    if string == "0" {
                        lengthRest += 1
                    } else { lengthNote += 1 }
                }
            previousInt = string
            }
        }
        if previousInt == "0" {
            restLengths.append(lengthRest)
            beatTypeToggle.append(0)
        } else {
            noteLengths.append(lengthNote)
            beatTypeToggle.append(1)
        }
        var iNote = 0
        var iRest = 0
        for type in beatTypeToggle {
            if type == 1 {
                lengthMaster.append(noteLengths[iNote])
                iNote += 1
            } else {
                lengthMaster.append(restLengths[iRest])
                iRest += 1
            }
        }
        var sumLengths = 0
        var sumSub = subDivision
        var typeMaster : [Int] = []
        var iType = 0
        var lengthOutput : [Int] = []
        for length in lengthMaster {
            sumLengths += length
            var initialType = 0
            if beatTypeToggle[iType] == 0 {
                typeMaster.append(0)
            } else {
                typeMaster.append(1)
                initialType = 1
            }
            iType += 1
            
            if sumLengths == sumSub {
                sumSub += subDivision
            }
            if sumLengths <= sumSub {
                lengthOutput.append(length)
            }
            var additiveLength = 0
            while sumLengths > sumSub {
                var extendedType = 0
                if initialType == 1 {
                    extendedType = 2
                }
                typeMaster.append(extendedType)
                let newAdditive = sumSub - (sumLengths - length + additiveLength)
                lengthOutput.append(newAdditive)
                additiveLength += newAdditive
                
                sumSub += subDivision
                if sumLengths < sumSub {
                    lengthOutput.append(sumLengths - (sumSub - subDivision))
                }
                if sumLengths == sumSub {
                    lengthOutput.append(subDivision)
                    sumSub += subDivision
                }
            }
        }
        print("The length Masters are : \(lengthOutput)")
        print("The type Masters are :   \(typeMaster)")
        imageNames = []
        iType = 0
        for length in lengthOutput {
            var newName = ""
            if typeMaster[iType] == 0 {
                newName += "Rest "
            } else {
                newName += "Note "
            }
            iType += 1
            if subDivision == 2 || subDivision == 3 {
                if (length % 2) == 0 {
                    let int = length / 2
                    newName += "\(int)"
                } else {
                    newName += "\(length):2"
                }
            } else {
                if (length % subDivision) == 0 {
                    let int = length / subDivision
                    newName += "\(int)"
                } else if subDivision == 4 && length == 2 {
                    newName += "1:2"
                } else {
                    newName += "\(length):\(subDivision)"
                }
            }
            newName += ".png"
            imageNames.append(newName)
        }
        if subDivision == 3 {
            beatIndicator.image = UIImage(named: "Note 3:2.png")
            numeraterOutlet.text = "\(beatCount * 3)"
            denominatorOutlet.text = "8"
        } else {
            beatIndicator.image = UIImage(named: "Note 1.png")
            numeraterOutlet.text = "\(beatCount)"
            denominatorOutlet.text = "4"
        }
        print(imageNames)
        let screenOffput = Int((UIScreen.mainScreen().bounds.width)/8)
        let screenWidth = screenOffput * 6
        sumLengths = 0
        for length in lengthOutput { sumLengths += length }
        let subWidth = screenWidth / 16
        let subDistance = screenWidth / sumLengths
        let subHeight = (subWidth * 4) / 3
        sumLengths = 0
        var previousLength = 0
        var index = 0
        for length in lengthOutput {
            createImage(imageNames[index], x: (subDistance * sumLengths) + (2*screenOffput), y: 60, w: subWidth, h: subHeight)
            if typeMaster[index] == 2 {
                createImage("Tie.png", x: (sumLengths - previousLength) * subDistance + (2*screenOffput), y: 65 + subHeight, w: (subDistance * (previousLength)) + (subDistance/4), h: subHeight/3)
            }
            sumLengths += length
            index += 1
            previousLength = length
        }
        
    }
    
    func createImage(name: String, x: Int, y: Int, w: Int, h: Int) {
        let image = UIImage(named: name)
        let imageView = UIImageView(image: image!)
        imageView.frame = CGRect(x: x, y: y, width: w, height: h)
        view.addSubview(imageView)
        arrayOfImages.append(imageView)
    }
    
    func resetExercise() {
        theOutput.text = ""
        generatedString = []
        generatedBeat = []
        answer = []
        beatCollection = []
        recordedTaps = []
        evaluationLabel.text = ""
        rightTouches = 0
        wrongTouches = 0
        for image in arrayOfImages {
            image.removeFromSuperview()
        }
        arrayOfImages = []
    }

    func initiateExercise() {
        metronomeColor = 240
        timeoffputcounter = 0
        rightTouches = 0
        wrongTouches = 0
        evaluationLabel.text = ""
        recordedTaps = []
        answer = []
        countOffLabel.text = "1"
        theButtonOutlet.enabled = false
        theTryAgainOutlet.enabled = false
        theRandomizeOutlet.enabled = false
        tempoCount = 1
        currentBeat = beatCount*2
        let interval : Double = (60 / Double(tempoValue))
        timeStep = (interval / Double(subDivision))
        time = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "tempo", userInfo: nil, repeats: true)
        timeoffput = NSTimer.scheduledTimerWithTimeInterval(interval / 10, target: self, selector: "tempoOffPut", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(time, forMode: NSRunLoopCommonModes)
        NSRunLoop.currentRunLoop().addTimer(timeoffput, forMode: NSRunLoopCommonModes)
    }
    
    @IBAction func theButton(sender: UIButton) {
        resetExercise()
        randomGenerate()
        initiateExercise()
        getAnswer()
        exerciseOutput()
    }
    
    @IBAction func theTryAgainMethod(sender: UIButton) {
        initiateExercise()
        getAnswer()
    }
    
    @IBAction func theRandomizeButton(sender: AnyObject) {
        beatStepperOutlet.value = Double(arc4random_uniform(3)) + 2.0
        beatCount = Int(beatStepperOutlet.value)
        beatValue.text = String(Int(beatStepperOutlet.value))
        
        subStepperOutlet.value = Double(arc4random_uniform(4)) + 1.0
        subDivision = Int(subStepperOutlet.value)
        subdivisionLabel.text = String(Int(subStepperOutlet.value))
        
        tempoStepperOutlet.value = (Double(arc4random_uniform(13)) + 6.0) * 10.0
        tempoValue = Int(tempoStepperOutlet.value)
        tempoLabel.text = String(Int(tempoStepperOutlet.value))
        
        levelStepperOutlet.value = Double(arc4random_uniform(4)) + 1
        level = Int(levelStepperOutlet.value)
        theLevelLabel.text = String(Int(levelStepperOutlet.value))
        
        intensityStepperOutlet.value = (Double(arc4random_uniform(10)) + 1.0) / 10.0
        intensity = Double(intensityStepperOutlet.value)
        theIntensityLabel.text = String(Double(intensityStepperOutlet.value))
        
        theTryAgainOutlet.enabled = false
        resetExercise()
        randomGenerate()
        initiateExercise()
        getAnswer()
        exerciseOutput()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        areaTouched()
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        areaReleased()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

