describe FactoryBot do
  example "all factories are valid" do
    expect{ FactoryBot.lint }.not_to raise_error
  end
end
