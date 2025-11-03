import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getTopOffenders from "@salesforce/apex/TopOffendersController.getTopOffenders";

export default class TopOffendersDashboard extends LightningElement {
  @track topOffendersData;
  @track isLoading = true;
  @track error;

  daysBack = 7; // Default to 7 days
  limitSize = 5; // Default to top 5

  connectedCallback() {
    this.loadTopOffenders();
  }

  async loadTopOffenders() {
    this.isLoading = true;
    this.error = undefined;

    try {
      this.topOffendersData = await getTopOffenders({
        limitSize: this.limitSize,
        daysBack: this.daysBack,
      });
    } catch (error) {
      this.error = error;
      this.showError("Failed to load top offenders", error.body?.message || error.message);
    } finally {
      this.isLoading = false;
    }
  }

  get hasSlowFlows() {
    return this.topOffendersData?.slowestFlows?.length > 0;
  }

  get hasHighCpuClasses() {
    return this.topOffendersData?.highestCpuClasses?.length > 0;
  }

  get hasApiConsumers() {
    return this.topOffendersData?.mostApiConsumers?.length > 0;
  }

  get lastUpdatedFormatted() {
    if (!this.topOffendersData?.lastUpdated) return "";
    return new Date(this.topOffendersData.lastUpdated).toLocaleString();
  }

  handleRefresh() {
    this.loadTopOffenders();
  }

  showError(title, message) {
    this.dispatchEvent(
      new ShowToastEvent({
        title: title,
        message: message,
        variant: "error",
      })
    );
  }
}
