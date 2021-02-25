defmodule PipeLogger do
  require Logger

  def debug(data, msg) do
    Logger.debug(msg)
    data
  end

  def info(data, msg) do
    Logger.info(msg)
    data
  end
end
