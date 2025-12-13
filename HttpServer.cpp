#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <string>
#include <thread>
#include <mutex>

#pragma comment(lib, "ws2_32.lib")

std::string latestJson = "";
std::mutex jsonMutex;
bool serverRunning = false;
std::thread serverThread;

void ServerLoop() {
    WSADATA wsaData;
    if (WSAStartup(MAKEWORD(2, 2), &wsaData) != 0) {
        return;
    }

    SOCKET listenSocket = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if (listenSocket == INVALID_SOCKET) {
        WSACleanup();
        return;
    }

    sockaddr_in serverAddr;
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_addr.s_addr = inet_addr("127.0.0.1");
    serverAddr.sin_port = htons(5000);

    if (bind(listenSocket, (sockaddr*)&serverAddr, sizeof(serverAddr)) == SOCKET_ERROR) {
        closesocket(listenSocket);
        WSACleanup();
        return;
    }

    if (listen(listenSocket, SOMAXCONN) == SOCKET_ERROR) {
        closesocket(listenSocket);
        WSACleanup();
        return;
    }

    while (serverRunning) {
        SOCKET clientSocket = accept(listenSocket, NULL, NULL);
        if (clientSocket == INVALID_SOCKET) {
            continue;
        }

        char buffer[1024];
        int bytesReceived = recv(clientSocket, buffer, sizeof(buffer), 0);
        if (bytesReceived > 0) {
            std::string request(buffer, bytesReceived);
            // Simple parsing for POST body
            size_t bodyStart = request.find("\r\n\r\n");
            if (bodyStart != std::string::npos) {
                std::string body = request.substr(bodyStart + 4);
                // Assume body is JSON
                std::lock_guard<std::mutex> lock(jsonMutex);
                latestJson = body;
            }

            // Send HTTP 200 OK response
            std::string response = "HTTP/1.1 200 OK\r\nContent-Type: application/json\r\nContent-Length: 15\r\n\r\n{\"status\":\"ok\"}";
            send(clientSocket, response.c_str(), (int)response.length(), 0);
        }
        closesocket(clientSocket);
    }

    closesocket(listenSocket);
    WSACleanup();
}

extern "C" __declspec(dllexport) void StartHttpServer() {
    if (!serverRunning) {
        serverRunning = true;
        serverThread = std::thread(ServerLoop);
        serverThread.detach();
    }
}

extern "C" __declspec(dllexport) void StopHttpServer() {
    serverRunning = false;
    if (serverThread.joinable()) {
        serverThread.join();
    }
}

extern "C" __declspec(dllexport) const char* GetLatestJson() {
    std::lock_guard<std::mutex> lock(jsonMutex);
    return latestJson.c_str();
}

extern "C" __declspec(dllexport) void ClearLatestJson() {
    std::lock_guard<std::mutex> lock(jsonMutex);
    latestJson = "";
}