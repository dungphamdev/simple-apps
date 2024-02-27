FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["simple-dotnet-app/simple-dotnet-app.csproj", "simple-dotnet-app/"]
RUN dotnet restore "simple-dotnet-app/simple-dotnet-app.csproj"
COPY . .
WORKDIR "/src/simple-dotnet-app"
RUN dotnet build "simple-dotnet-app.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "simple-dotnet-app.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "simple-dotnet-app.dll"]
