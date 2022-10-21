//
//  ContentView.swift
//  Scrumdinger
//
//  Created by Kevin on 6/15/22.
//

import SwiftUI
import AVFoundation

struct MeetingView: View {
    @Binding var scrum: DailyScrum
    //source of truth
    @StateObject var scrumTimer = ScrumTimer()
    @StateObject var speechRecognizer = SpeechRecognizer()
    @State private var isRecording = false
    
    private var player: AVPlayer { AVPlayer.sharedDingPlayer }
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16.0)
                .fill(scrum.theme.mainColor)
            VStack {
                MeetingHeaderView(secondsElapsed: scrumTimer.secondsElapsed, secondsRemaining: scrumTimer.secondsRemaining, theme: scrum.theme)
                MeetingTimerView(speakers: scrumTimer.speakers, theme: scrum.theme, isRecording: isRecording)   //no isRecording binding...
                MeetingFooterView(speakers: scrumTimer.speakers, skipAction: scrumTimer.skipSpeaker)
            }
        }
        .padding()
        .foregroundColor(scrum.theme.accentColor)
        .onAppear {
            //reset scrum timer
            scrumTimer.reset(lengthInMinutes: scrum.lengthInMinutes, attendees: scrum.attendees)
            scrumTimer.speakerChangedAction = {
                player.seek(to: .zero)    //plays audio file from beg.
                player.play()
            }
            //reset speech recognizer & transcribe
            speechRecognizer.reset()
            speechRecognizer.transcribe()
            isRecording = true
            
            //start scrum timer
            scrumTimer.startScrum()
        }
        .onDisappear {
            //stop scrum timer
            scrumTimer.stopScrum()
            
            //stop transcribing w/ speech recognizer
            speechRecognizer.stopTranscribing()
            isRecording = false
            
            //make new history for stopped scrum timer
            let newHistory = History(attendees: scrum.attendees, lengthInMinutes: scrum.timer.secondsElapsed / 60, transcript: speechRecognizer.transcript)
            scrum.history.insert(newHistory, at: 0) //insert at beg.
        }
        .navigationBarTitleDisplayMode(.inline) //?
    }
}

struct MeetingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            MeetingView(scrum: .constant(DailyScrum.sampleData[0]))
        }
    }
}
