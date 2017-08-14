<!--
{
  "title": "SooperLooper",
  "date": "2017-08-12T13:01:30+09:00",
  "category": "",
  "tags": [],
  "draft": false
}
-->


# SooperLooper overview

Summary

- sync (quantize) implementation
- recording methods (record/overdub/substitute/replace)
- managing jack port
- gui/midi control (via OSC)
- new feature consideration
  - metronome for sync internal mode (or dynamically generate metronome as looper from internal sync parameters)
  - fill empty record data so that I can start from dubmode with fixed length loop
      - create multiple of existing loop's length (applicable for sync internal mode and sync loop mode)
  - rewrite gui with qt
  - rewrite as lv2 plugin
  - should be able to delete loop not only last one
  - shorten existing loop


Based on my workflow, I follow this part:

- sync to 1st looper, quantize to loop
- record common input with monitoring on
- 1st looper start/stop record
- 2nd looper start/stop record with sync on
- 2nd looper start/stop overdub


```
[ Data structure ]
Engine
'-* Looper
  '-' _input_ports, _output_ports
  '-' LADSPA_Descriptor
  '-' LADSPA_Data ports[LASTPORT]
  '-' LADSPA_Handle (aka SooperLooperI) (could have 2 for stereo)
    '-' pSampleBuf (in memory sample)
    '-' state, nextState
    '-' ..
'-* RingBuffer<LoopManageEvent> (adding/removing looper)
'-' ControlOSC ??
'-' EventGenerator
'-* RingBuffer<Event> (syncing etc..) (Event is a tuple of Command, Controle, ..)
'-* port_id_t _common_inputs, _common_outputs
'-' std::vector<sample_t *> _common_input_buffers, _common_output_buffers
'-' ..

JackAudioDriver < AudioDriver
'-' jack_client_t
'-* jack_port_t _input_ports, _output_ports


[ Procedure ]

(Main thread)
- main =>
  - new JackAudioDriver
  - new Engine
  - Engine::initialize =>
    - JackAudioDriver::initialize =>
      - jack_set_process_callback(.. _process_callback ..)
    - JackAudioDriver::create_input_port("common_in_<N>") => jack_port_register
    - JackAudioDriver::create_output_port("common_out_<N>") => jack_port_register
    - new EventGenerator
    - new RingBuffer (for Event and some others)
    - calculate_tempo_frames
    - new ControlOSC =>
      - _osc_server = lo_server_new (from liblo)
      - Engine::LoopAdded.connect(.. ControlOSC::on_loop_added)
      - register_callbacks =>
        - lo_server_add_method (e.g. "/ping", "/register", ...)
      - on_loop_added =>
        - lo_server_add_method(_osc_server .. "/sl/-1/down" ..)
      - init_osc_thread => pthread_create(.. _osc_receiver)
  - JackAudioDriver::activate => jack_activate
  - Engine::mainloop =>
    - while
      - process_nonrt_event =>
        - (case PingEvent) => ControlOSC::send_pingack => lo_send(addr, retpath ..  _engine->loop_count() ..)
        - (case ConfigLoopEvent::Add) => add_loop =>
          - new Looper => initialize =>
            - create_sl_descriptor => ?? returns LADSPA_Descriptor
            - LADSPA_Descriptor.instantiate (ie instantiateSooperLooper) => ??
            - LADSPA_Descriptor.connect_port (ie connectPortToSooperLooper) => ??
            - LADSPA_Descriptor.activate (ie activateSooperLooper) => ??
            - JackAudioDriver::create_input_port("loopx_in_x"), create_output_port
          - add_loop =>
            - update_sync_source =>
              - _instances[(int)_sync_source - 1]->get_sync_out_buf
              - Looper::use_sync_buf
              - set_tempo ..
            - signal LoopAdded --> ControlOSC::on_loop_added =>
              - lo_server_add_method(_osc_server .. "/sl/%d/down" ..) ..
              - send_all_config => send_pingack ..
            - push_loop_manage_to_rt(.. LoopManageEvent::AddLoop)
      - ControlOSC::send_auto_updates =>
        - send_registered_auto_updates => lo_send for whole UrlListAuto


(Process thread)
- JackAudioDriver::_process_callback => Engine::process =>
  - process_rt_loop_manage_events =>
    - (case AddLoop) _rt_instances.push_back
    - ..
  - generate_sync =>
    - (assume we're using sync to one of Looper_s)
    - set_tempo, calculate_tempo_frames based on sync Looper's loop length and sample rate
    - check if current processing frame is the beginning of next qurter note (aka hit_at = 0)
    - if hit_at, _beat_occurred = true
  - handle rt event and run Looper instances alternatively based on event frame
    - do_global_rt_event => (not much ..)
    - Looper::do_event =>
      - (case Event::type_cmd_down)
        - requested_cmd = cmd (e.g. Event::Record (aka MULTI_RECORD in plugin.cc))
        - request_pending = true
      - (case Event::type_control_change)
        - ports[ev->Control] = ev->Value (eg SyncMode (in event.cpp) is Sync (in plugin.hpp))
    - Looper::run =>
      - if request_pending, ports[Multi] = requested_cmd
      - run_loops =>
        - com_obufs[n] = Engine::get_common_output_buffer
        - JackAudioDriver::get_input_port_buffer
        - JackAudioDriver::get_output_port_buffer
        - Engine::get_common_input_buffer
        - LADSPA_Descriptor.connect_port (AudioInputPort, AudioOutputPort, SyncInputPort, SyncOutputPort)
        - LADSPA_Descriptor.run (ie runSooperLooper) =>
          - .. state transition based on requested command and current state, for example ..
            - (if lMultiCtrl is MULTI_RECORD)
              - (if tate is currently STATE_RECORD)
                - if sync is on, state = STATE_TRIG_STOP, nextState = STATE_PLAY
                - otherwise, directly state = STATE_PLAY
              - (else) state = STATE_TRIG_START
            - (if lMultiCtrl is STATE_OVERDUB)
              - (if state is current STATE_OVERDUB) pLS->nextState = STATE_PLAY, pLS->waitingForSync = 1
              - (else) pLS->nextState = STATE_OVERDUB, pLS->waitingForSync = 1
          - .. process samples (audio buffer and sync buffer) based on state, for example ..
            - (if state is STATE_TRIG_START)
              - (if input exceeds threadshold or pfSyncInput is non-zero)
                - loop = pushNewLoopChunk
                - state = STATE_RECORD
              - (otherwise) pfOutput[lSampleIndex] = fDry * pfInput[lSampleIndex]
            - (if state is STATE_RECORD)
              - ensureLoopSpace
              - pLS->pSampleBuf[(loop->lLoopStart + lCurrPos) ..] = pLS->fLoopFadeAtten * pfInput[lSampleIndex]
              - pfOutput[lSampleIndex] = fDry * pfInput[lSampleIndex]
              - loop->dCurrPos = loop->dCurrPos + fRate
              - update loop->lLoopLength
            - (if state is STATE_OVERDUB)
              - lCurrPos, rCurrPos, rpCurrPos
              - pLoopSample = & pLS->pSampleBuf[ .. ]
              - rLoopSample = & pLS->pSampleBuf[ .. ] (going to modify a bit later frames in the sample buffer ?)
              - fillLoops => ??
              - pfOutput[lSampleIndex] = fWet * *(pLoopSample) + fDry * fInputSample
              - *(rLoopSample) = fLoopFadeAtten * fInputSample + .. * fFeedback * *(rLoopSample)
              - loop->dCurrPos = loop->dCurrPos + fRate
              - (if loop->dCurrPos >= loop->lLoopLength (ie current overdubbing frame passed original loop frames))
                - loop->dCurrPos = fmod(loop->dCurrPos, loop->lLoopLength)
            - (if state is STATE_TRIG_STOP)
              - (if not synced or it's exact frame to sync (ie pfSyncInput[lSampleIndex] != 0.0f))
                - loop->lLoopLength = lCurrPos, loop->lCycles = 1
                - transitionToNext
                - pLS->waitingForSync = 0
              - pfOutput[lSampleIndex] = fDry * fInputSample
            - (if state is STATE_PLAY)
              - if sync mode, pfSyncOutput[lSampleIndex] = pfSyncInput[lSampleIndex]
              - if quantize off or exact frame to do quantize, pfSyncOutput[lSampleIndex] = 2.0f
              - check play sync ..
              - fillLoops
              - pLoopSample = & pLS->pSampleBu[ .. ]
              - fInputSample = pfInputLatencyBuf[ .. ]
              - fOutputSample = tmpWet * (*pLoopSample) + fDry * fInputSampl
              - pfOutput[lSampleIndex] = fOutputSample
          - pLS->pfWaiting = waitingForSync or state is STATE_TRIG_START or STATE_TRIG_STOP
          - update pfLoopPos, pfLoopLength, pfCycleLength
          - NOTE: fSyncMode (0.0, 1.0 (sync), 2.0 (relative sync))
          - NOTE: pfSyncInput and pfSyncOutput is sequence of flag indicating which frame to trigger sync
    - do_push_control_event => ..


(OSC thread)
- ControlOSC::osc_receiver =>
  - lo_server_get_socket_fd(_osc_server)CommandInfo
  - while
    - poll
    - lo_server_recv => .. =>
      - (case "/ping") _ping_handler => ping_handler => Engine::push_nonrt_event(new PingEvent)
      - (case "/loop_add") _loop_add_handler => Engine::push_nonrt_event(new ConfigLoopEvent(ConfigLoopEvent::Add ..))
      - (case "/sl/%d/down") _updown_handler =>
        - CommandInfo, CommandMap::to_command_t (eg str_cmd_map["record"] = Event::RECORD)
        - Engine::push_command_event ..
      - ..
```


Gui process

```
[ Procedure ]

(Main)
- IMPLEMENT_APP(SooperLooperGui::GuiApp) => .. =>
  - GuiApp::OnInit =>
    - new AppFrame => new MainPanel =>
      - new LoopControl =>
        - _osc_server = lo_server_new, lo_server_add_method (e.g. _pingack_handler)
        - new LoopUpdateTimer
        - init_traffic_thread => pthread_create(.. LoopControl::_osc_traffic ..)
      - init =>
        - LoopControl::LooperConnected.connect(.. &MainPanel::init_loopers)
        - LoopControl::NewDataReady.connect(.. &MainPanel::osc_data_ready)
      - _update_timer = new wxTimer, Start (cf. EVT_TIMER(ID_UpdateTimer, MainPanel::OnUpdateTimer))
    - AppFrame::Show
  - GuiApp::OnRun =>
    - LoopControl::connect =>
      - _osc_addr = lo_address_new
      - lo_send(_osc_addr, "/ping", "ssi", _our_url.c_str(), "/pingack", 1)
        (NOTE: spawn_looper if there's no pingack from engine process later)
      - LoopUpdateTimer::Start (will Notify LoopControl::pingtimer_expired)
    - wxApp::OnRun


(Timers)
- LoopUpdateTimer::Notify => LoopControl::pingtimer_expired =>
  - update_values => while lo_server_recv_noblock (_osc_server ..) =>
    - .. execute registered handlers for requests ..
    - (case "/pingack") => pingack_handler =>
      - _osc_addr = lo_address_new_from_url
      - lo_send(_osc_addr, "/register" ..)
      - register_global_updates => lo_send(_osc_addr, "/register_update" .. "tempo" ..) ..
      - signal LooperConnected -->
        - MainPanel::init_loopers =>
          - new LooperPanel as many as engine's Looper
          - register_all_in_new_thread => pthread_create(.. &LoopControl::_register_all) =>
            - (from new thread)
            - request_global_values => lo_send(_osc_addr, "/get", "sss", "tempo" ..) ..
            - register_auto_updates => lo_send(_osc_addr, "/sl/%d/register_auto_update" .. "state" ..) ..
            - register_input_controls => lo_send(.. "/sl/%d/register_update" ..)
            - request_all_values => lo_send(.. "/sl/%d/get" .. "rec_thresh" ..)
    - (case "/ctrl") => control_handler =>
      - update _global_val_map (current state of global menu)
      - update _params_val_map (current state of loopers)
        NOTE: when loopers are added/removed on engine, it will send us "/pingack",
              which essentially refreshes whole gui state by calling pingack_handler (ie MainPanel::init_loopers)
  - if no ack, spawn_looper => wxExecute("sooperlooper" ..)

- MainPanel::OnUpdateTimer =>
  - LoopControl::update_values => ..
  - check engine's liveness ..


(UI view update)
- MainPanel::OnIdle =>
  - if _got_new_data (NOTE: OSC thread's gonna set this up)
    - LoopControl::update_values (SEE ABOVE)
    - LooperPanel::update_controls => ..
    - update_controls => ..


(UI action)
- [Loop add/remove]
  - AppFrame::on_add_loop => MainPanel::do_add_loop =>
    - LoopControl::post_add_loop => lo_send(_osc_addr, "/loop_add" ..)
    - (TODO: how is UI updated after this ??)

- [Record start/stop]
  - LooperPanel::pressed_events => LoopControl::post_down_event =>
    - lo_send(.. "/sl/%d/down" .. "record")


(OSC thread)
- LoopControl::_osc_traffic =>
  - lo_server_get_socket_fd(_osc_server)
  - while
    - poll readability (ofcourse it doesn't really read)
    - signal NewDataReady --> MainPanel::osc_data_ready => wxWakeUpIdle
```


# Reference

- [sooperlooper](http://essej.net/sooperlooper/)
- OSC spec
