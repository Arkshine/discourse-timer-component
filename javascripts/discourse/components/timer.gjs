import Component from "@glimmer/component";
import { tracked } from "@glimmer/tracking";
import { fn } from "@ember/helper";
import { on } from "@ember/modifier";
import { action } from "@ember/object";
import { notEmpty } from "@ember/object/computed";
import { cancel, later, next } from '@ember/runloop';
import concatClass from "discourse/helpers/concat-class";
import DButton from "discourse/components/d-button";

export default class Timer extends Component {
  @tracked seconds = 0;
  @tracked timer = null;
  initialSeconds = 0;

  @notEmpty("timer") counterRunning;

  <template>
    <div id="tailor-timer">
      <div class="buttons">
        <DButton
          @class="read-task"
          @action={{fn this.start settings.read_task_timer}}
          @label={{themePrefix "read_task"}}
          @disabled={{this.timerButtonsDisabled}}
        />
        <DButton
          @class="enter-room"
          @action={{fn this.start settings.enter_room_timer}}
          @label={{themePrefix "enter_room"}}
          @disabled={{this.timerButtonsDisabled}}
        />
      </div>

      <div
        class={{concatClass "timer" (if this.stopButtonDisabled "disabled")}}
        {{on "click" this.togglePause}}
      >{{this.formatedTimer}}</div>

      <div class="buttons">
        <DButton
          @class="pause"
          @action={{this.togglePause}}
          @label={{this.pauseButtonLabel}}
          @disabled={{this.stopButtonDisabled}}
        />
        <DButton
          @class="stop"
          @action={{this.stop}}
          @label={{themePrefix "stop"}}
          @disabled={{this.stopButtonDisabled}}
        />
      </div>
    </div>
  </template>

  @action
  start(duration) {
    this.seconds = this.initialSeconds = duration;
    this.#startCounter();
  }

  @action
  stop() {
    this.#stopCounter();
    this.seconds = 0;
  }

  @action
  togglePause() {
    this.counterRunning ? this.#stopCounter() : this.#startCounter();
  }

  get pauseButtonLabel() {
    return !this.counterRunning && !this.seconds
      ? themePrefix("waiting")
      : themePrefix(this.counterRunning ? "pause" : "resume");
  }

  get stopButtonDisabled() {
    return !this.counterRunning && this.seconds === 0;
  }

  get timerButtonsDisabled() {
    return !this.stopButtonDisabled;
  }

  get formatedTimer() {
    const formatTime = (time) => (time < 10 ? "0" + time : time);
    const minutes = formatTime(Math.floor(this.seconds / 60));
    const seconds = formatTime(this.seconds % 60);

    return `${minutes}:${seconds}`;
  }

  willDestroy() {
    super.willDestroy(...arguments);
    this.#stopCounter();
  }

  #startCounter() {
    next(this, function () {
      this.timer = this.#runCounter();
    });
  }

  #runCounter() {
    return later(
      this,
      function () {
        this.seconds = this.seconds <= 0 ? this.initialSeconds : this.seconds - 1;
        this.timer = this.#runCounter();
      },
      1000
    );
  }

  #stopCounter() {
    cancel(this.timer);
    this.timer = null;
  }
}
