/**
 * PollingManager - A reusable utility for managing polling intervals with visibility handling
 * 
 * This class provides a centralized way to handle periodic polling with support for:
 * - Dynamic interval updates
 * - Automatic pause/resume on tab visibility changes
 * - Safe timer cleanup
 * 
 * @class PollingManager
 */
export default class PollingManager {
  /**
   * Creates a new PollingManager instance
   * @param {Function} callback - Function to call on each poll interval
   * @param {number} intervalMs - Initial polling interval in milliseconds
   */
  constructor(callback, intervalMs) {
    if (typeof callback !== 'function') {
      throw new TypeError('callback must be a function');
    }
    if (typeof intervalMs !== 'number' || intervalMs <= 0) {
      throw new TypeError('intervalMs must be a positive number');
    }

    this.callback = callback;
    this.intervalMs = intervalMs;
    this.timerId = null;
    this.isRunning = false;
    this.visibilityHandlerSetup = false;
    this.handleVisibilityChange = this.handleVisibilityChange.bind(this);
  }

  /**
   * Starts the polling timer if not already running and tab is visible
   */
  start() {
    if (!this.isRunning && document.visibilityState === 'visible') {
      this.isRunning = true;
      this.timerId = setInterval(() => {
        try {
          this.callback();
        } catch (error) {
          /* eslint-disable no-console */
          console.error('PollingManager: Error in callback', error);
        }
      }, this.intervalMs);
    }
  }

  /**
   * Stops the polling timer and cleans up resources
   */
  cleanup() {
    if (this.timerId) {
      clearInterval(this.timerId);
      this.timerId = null;
    }
    this.isRunning = false;
    
    if (this.visibilityHandlerSetup) {
      document.removeEventListener('visibilitychange', this.handleVisibilityChange);
      this.visibilityHandlerSetup = false;
    }
  }

  /**
   * Sets up visibility change handling (idempotent - can be called multiple times safely)
   * Automatically pauses polling when tab is hidden and resumes when visible
   */
  setupVisibilityHandling() {
    if (!this.visibilityHandlerSetup) {
      document.addEventListener('visibilitychange', this.handleVisibilityChange);
      this.visibilityHandlerSetup = true;
    }
  }

  /**
   * Updates the polling interval and restarts the timer with the new interval
   * @param {number} newIntervalMs - New polling interval in milliseconds
   */
  updateInterval(newIntervalMs) {
    if (typeof newIntervalMs !== 'number' || newIntervalMs <= 0) {
      throw new TypeError('newIntervalMs must be a positive number');
    }

    this.intervalMs = newIntervalMs;
    
    // Restart timer with new interval if currently running
    if (this.isRunning) {
      if (this.timerId) {
        clearInterval(this.timerId);
        this.timerId = null;
      }
      this.isRunning = false;
      this.start();
    }
  }

  /**
   * Handles visibility state changes
   * @private
   */
  handleVisibilityChange() {
    if (document.visibilityState === 'visible') {
      // Resume polling when tab becomes visible
      this.start();
      // Run immediate tick when becoming visible
      try {
        this.callback();
      } catch (error) {
        /* eslint-disable no-console */
        console.error('PollingManager: Error in immediate callback', error);
      }
    } else {
      // Pause polling when tab is hidden
      if (this.timerId) {
        clearInterval(this.timerId);
        this.timerId = null;
      }
      this.isRunning = false;
    }
  }
}
