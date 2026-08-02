FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
LABEL org.opencontainers.image.title="RentACar API" \
      org.opencontainers.image.description="ASP.NET Core Web API for a Rent A Car backend" \
      org.opencontainers.image.source="https://github.com/utku9012/rentacar-backend-api" \
      org.opencontainers.image.licenses="MIT"

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["RentACarApi.csproj", "./"]
COPY ["packages.lock.json", "./"]
RUN dotnet restore "RentACarApi.csproj" --locked-mode
COPY . .
RUN dotnet publish "RentACarApi.csproj" -c Release -o /app/publish --no-restore /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /app/publish .
USER 1654
ENTRYPOINT ["dotnet", "RentACarApi.dll"]
