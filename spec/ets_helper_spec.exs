defmodule Settings.EtsHelperSpec do
  use ESpec
  alias Settings.EtsHelper

  before do
    case :ets.info(EtsHelper._table) do
      :undefined -> :ok
      _ -> :ets.delete(EtsHelper._table)
    end
  end

  describe "set/get" do
    it "allows setting/retrieving a k/v" do
      expect(EtsHelper.set(:key, :value)) |> to(eq(:ok))
      expect(EtsHelper.get(:key)) |> to(eq(:value))
    end
  end

  describe "get" do
    it "returns nil if key missing" do
      expect(EtsHelper.get(:key)) |> to(eq(nil))
    end
  end

  describe "del" do
    it "removes a key" do
      EtsHelper.set(:key, :value)
      expect(EtsHelper.get(:key)) |> to(eq(:value))
      expect(EtsHelper.del(:key)) |> to(eq(:ok))
      expect(EtsHelper.get(:key)) |> to(eq(nil))
    end
  end

  describe "clear" do
    it "empties the table" do
      EtsHelper.set(:key, :value)
      expect(EtsHelper.get(:key)) |> to(eq(:value))
      expect(EtsHelper.clear()) |> to(eq(:ok))
      expect(EtsHelper.get(:key)) |> to(eq(nil))
    end
  end
end
