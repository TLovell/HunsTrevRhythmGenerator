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
    
    var beatCount = 4
    var subDivision = 2
    var beatCollection : [String] = []
    var generatedBeat : [Int] = []
    var generatedString : [String] = []
    var startTime = NSTimeInterval()
    var time = NSTimer()
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
        switch currentBeat {
        case 3...(beatCount*2):
            currentBeat -= 1
            countOffLabel.text = String(currentBeat)
        case 2:
            currentBeat -= 1
            exerciseRunning = true
            startTime = NSDate.timeIntervalSinceReferenceDate()
            countOffLabel.text = "Ready!"
        case (2-beatCount)...0:
            currentBeat -= 1
        case 1:
            countOffLabel.text = "Go!"
            currentBeat -= 1
        case (1-beatCount):
            currentBeat = 0
            countOffLabel.text = ""
            time.invalidate()
            enableButtons()
            exerciseRunning = false
            print(recordedTaps)
            checkAnswer()
        default:
            break;
        }
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
        print(onBeat)
        print(tapTime)
        if onBeat == true {
            tapArea.backgroundColor = UIColor.greenColor()
            rightTouches += 1
        } else {
            wrongTouches += 1
            tapArea.backgroundColor = UIColor.redColor()
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
        print(beatLevelAssignment)
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
        print(beatCollection)
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
        print(generatedString)
        print(generatedBeat)
        for count in 1...(beatCount-1) { //adds spaces in the string output for readability
            let reverseCount = beatCount - count
            generatedString.insert(" ", atIndex: (reverseCount * subDivision))
        }
        for integer in generatedString { //outputs the exercise to the UI
            theOutput.text! += integer
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
        tapArea.backgroundColor = UIColor.blueColor()
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
            print(answer)
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
    }

    func initiateExercise() {
        rightTouches = 0
        wrongTouches = 0
        evaluationLabel.text = ""
        recordedTaps = []
        answer = []
        countOffLabel.text = String(beatCount*2)
        theButtonOutlet.enabled = false
        theTryAgainOutlet.enabled = false
        theRandomizeOutlet.enabled = false
        currentBeat = beatCount*2
        let interval : Double = (60 / Double(tempoValue))
        timeStep = (interval / Double(subDivision))
        time = NSTimer.scheduledTimerWithTimeInterval(interval, target: self, selector: "tempo", userInfo: nil, repeats: true)
        NSRunLoop.currentRunLoop().addTimer(time, forMode: NSRunLoopCommonModes)
    }
    
    @IBAction func theButton(sender: UIButton) {
        resetExercise()
        randomGenerate()
        initiateExercise()
        getAnswer()
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

