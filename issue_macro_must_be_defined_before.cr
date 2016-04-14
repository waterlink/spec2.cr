require "./src/spec2"

Spec2.describe "an issue" do
  it "fails with 'macro must be defined before'" do
    expect do
      42
    end.to raise_error(Exception)
  end
end
