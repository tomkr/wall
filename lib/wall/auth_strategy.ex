defmodule Wall.AuthStrategy do
  @doc "Deal with the submitted parameters to log the user in using his account."
  @callback call(params :: map) :: tuple
end
