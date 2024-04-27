#include <stdio.h>

#include "raylib.h"

#define SCREEN_WIDTH 1024
#define SCREEN_HEIGHT 1024

typedef struct Ball {
    Vector2 position;
    Vector2 speed;
    int radius;
    bool active;
} Ball;

static Ball ball = {0};

int main(void) {
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Test");

    Vector2 paddle_position = {500, 900};
    Vector2 paddle_size = {100, 15};

    ball.position = (Vector2){510, 900};
    ball.speed = (Vector2){0, 0};
    ball.radius = 7;
    ball.active = false;

    SetTargetFPS(60);

    while (!WindowShouldClose()) {
        if (IsKeyDown(KEY_LEFT))  paddle_position.x -= 3.0f;
        if (IsKeyDown(KEY_RIGHT)) paddle_position.x += 3.0f;

        if (!ball.active) {
            if (IsKeyPressed(KEY_SPACE)) {
                ball.active = true;
                ball.speed = (Vector2){0, -5};
            }
        }

        if (ball.active) {
            ball.position.x += ball.speed.x;
            ball.position.y += ball.speed.y;
        }

        if (((ball.position.x + ball.radius) >= SCREEN_WIDTH) || ((ball.position.x + ball.radius) <= 0)) 
            ball.speed.x *= -1;
        if ((ball.position.y - ball.radius) <= 0) 
            ball.speed.y *= -1;
        if ((ball.position.y + ball.radius) >= SCREEN_HEIGHT) {
            ball.speed = (Vector2){0, 0};
            ball.active = false;
        }
   
        
        if (CheckCollisionCircleRec(ball.position, ball.radius, (Rectangle){paddle_position.x - paddle_size.x/2, paddle_position.y - paddle_size.y/2, paddle_size.x, paddle_size.y})) {
            if (ball.speed.y > 0) {
                ball.speed.y *= -1;
                ball.speed.x = (ball.position.x - paddle_position.x) / ((paddle_size.x/2) * 5);
            }
        }

        BeginDrawing();
            ClearBackground(RAYWHITE);
            DrawText("Breakout", 400, SCREEN_HEIGHT / 2, 50, LIGHTGRAY);
            DrawCircleV(ball.position, ball.radius, BLACK);
            DrawRectangleV(paddle_position, paddle_size, BLACK);
        EndDrawing();
    }
    CloseWindow();
    return 0;
}
