/**
 * PollingManager - Manages periodic polling with visibility handling and dynamic interval updates
 */
export default class PollingManager {
  /**
   * Creates a new PollingManager instance
   * @param {Function} callback - Function to call on each poll
   * @param {number} intervalMs - Polling interval in milliseconds
   */
  constructor(callback, intervalMs) {
    this.callback = callback;
    this.intervalMs = intervalMs;
    this.timerId = null;
    this.isRunning = false;
    this.visibilityHandlerSetup = false;
    this.visibilityHandler = null;
  }

  /**
   * Starts the polling timer
   */
  start() {
    if (!this.isRunning && document.visibilityState === "visible") {
      this.isRunning = true;
      this.timerId = setInterval(this.callback, this.intervalMs);
    }
  }

  /**
   * Stops and cleans up the polling timer and removes visibility listener
   */
  cleanup() {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
    this.isRunning = false;

    // Remove visibility handler if it was set up
    if (this.visibilityHandlerSetup && this.visibilityHandler) {
      document.removeEventListener("visibilitychange", this.visibilityHandler);
      this.visibilityHandlerSetup = false;
      this.visibilityHandler = null;
    }
  }

  /**
   * Sets up visibility change handling (idempotent - only registers once)
   */
  setupVisibilityHandling() {
    if (this.visibilityHandlerSetup) {
      return;
    }

    this.visibilityHandler = () => {
      if (document.visibilityState === "visible") {
        // Resume polling when tab becomes visible
        this.start();
        this.callback(); // Call immediately when becoming visible
      } else {
        // Pause polling when tab is hidden
        this.cleanup();
      }
    };

    document.addEventListener("visibilitychange", this.visibilityHandler);
    this.visibilityHandlerSetup = true;
  }

  /**
   * Updates the polling interval. If currently running, restarts the timer
   * with the new interval without re-registering visibility handlers.
   * @param {number} newIntervalMs - New polling interval in milliseconds
   */
  updateInterval(newIntervalMs) {
    this.intervalMs = newIntervalMs;

    if (this.isRunning) {
      // Clear existing timer
      if (this.timerId) {
        clearInterval(this.timerId);
        this.timerId = null;
      }
      // Restart with new interval
      this.timerId = setInterval(this.callback, this.intervalMs);
    }
  }
}
