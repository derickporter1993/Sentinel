/**
 * PollingManager - utility to manage periodic polling with optional visibility handling.
 */
export default class PollingManager {
  /**
   * @param {number} intervalMs - Initial polling interval in milliseconds.
   * @param {Function} callback - Function to invoke on each poll.
   */
  constructor(intervalMs, callback) {
    this.intervalMs = intervalMs;
    this.callback = callback;
    this.timer = null;
    this.visibilityHandler = null;
  }

  /** Starts the polling timer when the document is visible. */
  start() {
    if (!this.timer && typeof document !== "undefined" && document.visibilityState === "visible") {
      this.timer = setInterval(() => this.callback(), this.intervalMs);
    }
  }

  /** Stops any active polling timer. */
  stop() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  /**
   * Updates the polling interval and restarts the timer if it was running.
   * @param {number} newIntervalMs - New polling interval in milliseconds.
   */
  updateInterval(newIntervalMs) {
    this.intervalMs = newIntervalMs;
    if (this.timer) {
      this.stop();
      this.start();
    }
  }

  /**
   * Sets up handlers to pause polling when the document is hidden and resume when visible.
   */
  setupVisibilityHandling() {
    if (this.visibilityHandler || typeof document === "undefined") {
      return;
    }

    this.visibilityHandler = () => {
      if (document.visibilityState === "visible") {
        this.start();
        this.callback();
      } else {
        this.stop();
      }
    };

    document.addEventListener("visibilitychange", this.visibilityHandler);
  }

  /** Cleans up timers and listeners. */
  cleanup() {
    this.stop();
    if (this.visibilityHandler && typeof document !== "undefined") {
      document.removeEventListener("visibilitychange", this.visibilityHandler);
      this.visibilityHandler = null;
    }
  }
}
