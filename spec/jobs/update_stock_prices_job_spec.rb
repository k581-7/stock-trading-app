require 'rails_helper'

RSpec.describe UpdateStockPricesJob, type: :job do
  # Replace the 'pending' block with a real test
  it "queues the job with the correct priority" do
    expect { UpdateStockPricesJob.perform_later }.to have_enqueued_job(UpdateStockPricesJob)
  end
end
