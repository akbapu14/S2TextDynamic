/**
 * Copyright IBM Corporation 2016
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 **/

import UIKit
import SpeechToTextV1
class MicrophoneViewController: UIViewController {

    var speechToText: SpeechToText!
    var speechToTextSession: SpeechToTextSession!
    var isStreaming = false
    var allLabels: [SpeakerLabel] = []
//    var results: SpeechRecognitionResults!
    @IBOutlet var audioView: SwiftSiriWaveformView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var s2View: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        audioView.amplitude = 1.0
        audioView.backgroundColor = UIColor.black
        speechToText = SpeechToText(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
        speechToTextSession = SpeechToTextSession(
            username: Credentials.SpeechToTextUsername,
            password: Credentials.SpeechToTextPassword
        )
    }
    
    @IBAction func didPressMicrophoneButton(_ sender: UIButton) {
        streamMicrophoneBasic()
    }
    
    /**
     This function demonstrates how to use the basic
     `SpeechToText` class to transcribe microphone audio.
     */
    public func streamMicrophoneBasic() {
        if !isStreaming {
            
            // update state
            microphoneButton.setTitle("Stop Microphone", for: .normal)
            isStreaming = true
            
            // define recognition settings
            var settings = RecognitionSettings(contentType: .opus)
            settings.continuous = true
            settings.interimResults = true
            settings.speakerLabels = true
            
            // define error function
            let failure = { (error: Error) in print(error) }
            
            // start recognizing microphone audio
            speechToText.recognizeMicrophone(settings: settings, customizationID: "ba3fc280-8135-11e7-8345-e7d365637ecb", failure: failure) {
                results in
                self.textView.text = results.bestTranscript
//                self.results = results
//                for label in results.speakerLabels {
//                    if label != nil {
//                        self.allLabels.append(label)
//                    }
//                }
            }
            
        } else {
            
            // update state
            microphoneButton.setTitle("Start Microphone", for: .normal)
            isStreaming = false
            
            // stop recognizing microphone audio
            speechToText.stopRecognizeMicrophone()
//            let labels = self.results.speakerLabels
            var firstString = ""
            var secondString = ""
//            for speechInstance in results.results {
//                let timetomatch = (speechInstance.alternatives[0].timestamps?[0].endTime)! - 0.01
//                var matched = false
//                for label in labels {
//                    if (timetomatch > label.fromTime && timetomatch < label.toTime) {
//                        if matched == false {
//                            matched = true
//                            if label.speaker == 0 {
//                                firstString += speechInstance.alternatives[0].transcript
//                                break
//                            } else {
//                                secondString += speechInstance.alternatives[0].transcript
//                                break
//                            }
//                        }
//
//                    }
//                    if matched == false {
//                        firstString += speechInstance.alternatives[0].transcript
//                        matched = true
//                        break
//                    }
//                }
//            }
//            textView.text = firstString
//            s2View.text = secondString
//            print(self.allLabels)
        }
    }
    
    /**
     This function demonstrates how to use the more advanced
     `SpeechToTextSession` class to transcribe microphone audio.
     */
    public func streamMicrophoneAdvanced() {
        if !isStreaming {
            
            // update state
            microphoneButton.setTitle("Stop Microphone", for: .normal)
            isStreaming = true
            
            // define callbacks
            speechToTextSession.onConnect = { print("connected") }
            speechToTextSession.onDisconnect = { print("disconnected") }
            speechToTextSession.onError = { error in print(error) }
            speechToTextSession.onPowerData = { decibels in print(decibels) }
            speechToTextSession.onMicrophoneData = { data in print("received data") }
            speechToTextSession.onResults = { results in self.textView.text = results.bestTranscript }
            
            // define recognition settings
            var settings = RecognitionSettings(contentType: .opus)
            settings.continuous = true
            settings.interimResults = true
            
            // start recognizing microphone audio
            speechToTextSession.connect()
            speechToTextSession.startRequest(settings: settings)
            speechToTextSession.startMicrophone()
            
        } else {
            
            // update state
            microphoneButton.setTitle("Start Microphone", for: .normal)
            isStreaming = false
            
            // stop recognizing microphone audio
            speechToTextSession.stopMicrophone()
            speechToTextSession.stopRequest()
            speechToTextSession.disconnect()
        }
    }
}
