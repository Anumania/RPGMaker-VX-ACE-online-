// dllmain.cpp : Defines the entry point for the DLL appication.
#define fn_export extern "C" __declspec (dllexport)
#define WIN32_LEAN_AND_MEAN
//#define _CRT_SECURE_NO_WARNINGS

#include <windows.h>
#include <winsock2.h>
#include <ws2tcpip.h>
#include <stdlib.h>
#include <stdio.h>
#include <codecvt>
#include <string>
#include <locale>
#include <stdio.h>
#include <iostream>
#include <thread>



// Need to link with Ws2_32.lib, Mswsock.lib, and Advapi32.lib
#pragma comment (lib, "Ws2_32.lib")
#pragma comment (lib, "Mswsock.lib")
#pragma comment (lib, "AdvApi32.lib")


#define DEFAULT_BUFLEN 64
#define DEFAULT_PORT "27015"

char argv[20][20];
const int argc = 2;
const char* ip = "192.168.7.117";

WSADATA wsaData;
SOCKET ConnectSocket = INVALID_SOCKET;
struct addrinfo* result = NULL,
    * ptr = NULL,
    hints;

char recvbuf[DEFAULT_BUFLEN];
int iResult;
int recvbuflen = DEFAULT_BUFLEN;
bool yeah;

char* input = (char*)"";

int socketNum = -16800;
char* buffer;

void thred(int sockey) {
    while (true) {
        if (socketNum != INVALID_SOCKET) {
            char recsbuf[DEFAULT_BUFLEN];
            int aresult = recv(sockey, recvbuf, recvbuflen, 0);
            //printf("%u", strlen(recsbuf));
        }
        Sleep(15);
    }
    return;
}

fn_export class net {
public:
    int net_init_a(char* message) {
        yeah = true;
        const char* sendbuf = message;
        // Validate the parameters
        if (argc != 2) {
            printf("usage: %s server-name\n", argv[0]);
            return 1;
        }



        // Initialize Winsock
        iResult = WSAStartup(MAKEWORD(2, 2), &wsaData);
        if (iResult != 0) {
            printf("WSAStartup failed with error: %d\n", iResult);
            return 1;
        }

        ZeroMemory(&hints, sizeof(hints));
        hints.ai_family = AF_UNSPEC;
        hints.ai_socktype = SOCK_STREAM;
        hints.ai_protocol = IPPROTO_TCP;

        // Resolve the server address and port
        iResult = getaddrinfo(ip, DEFAULT_PORT, &hints, &result);
        if (iResult != 0) {
            printf("getaddrinfo failed with error: %d\n", iResult);
            WSACleanup();
            return 1;
        }

        // Attempt to connect to an address until one succeeds
        for (ptr = result; ptr != NULL; ptr = ptr->ai_next) {

            // Create a SOCKET for connecting to server
            ConnectSocket = socket(ptr->ai_family, ptr->ai_socktype,
                ptr->ai_protocol);
            if (ConnectSocket == INVALID_SOCKET) {
                printf("socket failed with error: %ld\n", WSAGetLastError());
                WSACleanup();
                return 1;
            }

            // Connect to server.

            iResult = connect(ConnectSocket, ptr->ai_addr, (int)ptr->ai_addrlen);
            if (iResult == SOCKET_ERROR) {
                closesocket(ConnectSocket);
                ConnectSocket = INVALID_SOCKET;
                continue;
            }
            return ConnectSocket;
        }

        freeaddrinfo(result);

        if (ConnectSocket == INVALID_SOCKET) {
            printf("Unable to connect to server!\n");
            WSACleanup();
            return 1;
        }

        return ConnectSocket;
    }
};

static net bruh;

fn_export int a_net_setup(char* message)
{   
    int a = bruh.net_init_a(message);
    std::thread (thred, a).detach();
    return a;
}
fn_export int a_net_send(int socket, char* message, int len)
{   
    try {
        
        if (socket == INVALID_SOCKET) {
            return 1;
        }
        
        iResult = send(socket, message, len, 0);
        if (iResult == SOCKET_ERROR) {
            printf("send failed with error: %d\n", WSAGetLastError());
            //closesocket(ConnectSocket);
            //WSACleanup();
            return 1;
        }
        
    }
    catch (std::exception e) {
        //std::cout << (e.what());
        printf("what");
    }
    return 0;
}
fn_export char* a_net_receive(int socket, char* test) {
    for (int i = 0; i < DEFAULT_BUFLEN; i++) {
        test[i] = (int)recvbuf[i];
    }
    return recvbuf;//ary;
}
fn_export int a_net_disconnect(int socket)
{
    closesocket(ConnectSocket);
    WSACleanup();
    return 0;
}
