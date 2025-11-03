/**
 * Polling Manager Utility
 * Provides reusable polling functionality with visibility change handling
 */

export class PollingManager {
  constructor(callback, interval = 60000) {
    this.callback = callback;
    this.interval = interval;
    this.timer = null;
    this.visibilityHandler = null;
  }

  start() {
    if (!this.timer && document.visibilityState === 'visible') {
      this.timer = setInterval(() => this.callback(), this.interval);
    }
  }

  stop() {
    if (this.timer) {
      clearInterval(this.timer);
      this.timer = null;
    }
  }

  updateInterval(newInterval) {
    this.interval = newInterval;
    // Restart polling with new interval
    this.stop();
    this.start();
  }

  handleVisibilityChange = () => {
    if (document.visibilityState === 'visible') {
      this.start();
      this.callback(); // Load immediately when becoming visible
    } else {
      this.stop();
    }
  };

  setupVisibilityHandling() {
    this.visibilityHandler = this.handleVisibilityChange;
    document.addEventListener('visibilitychange', this.visibilityHandler);
  }

  cleanup() {
    this.stop();
    if (this.visibilityHandler) {
      document.removeEventListener('visibilitychange', this.visibilityHandler);
      this.visibilityHandler = null;
    }
  }
}
