const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const WIDTH: i16 = 1024;
const HEIGHT: i16 = 1024;

const BALL = struct {
    x: f32,
    y: f32,
    speed_x: f32,
    speed_y: f32,
    radius: f32,
    color: rl.Color,
};

pub fn main() !void {
    var paddle = rl.Rectangle{ .x = 462, .y = 900, .height = 10, .width = 100 };
    var ball = BALL{ .x = @as(f32, WIDTH / 2), .y = paddle.y - paddle.height, .speed_x = 5, .speed_y = -5, .radius = 5, .color = rl.BLUE };
    var game_started = false;

    rl.InitWindow(1024, 1024, "Breakout");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        rl.BeginDrawing();
        defer rl.EndDrawing();

        const key_pressed: c_int = rl.GetKeyPressed();
        if (key_pressed != 0) {
            std.debug.print("key: {d}\n", .{key_pressed});
        }
        if (rl.IsKeyReleased(32)) // space-bar
            game_started = true;

        if (game_started) { // space-bar

            // ball movement
            ball.x += ball.speed_x;
            ball.y += ball.speed_y;

            // ball collision with walls
            if (ball.x - ball.radius <= 0 or ball.x + ball.radius >= WIDTH)
                ball.speed_x *= -1;
            if (ball.y - ball.radius <= 0)
                ball.speed_y *= -1;

            // ball collision with paddle
            if (rl.CheckCollisionCircleRec(rl.Vector2{ .x = ball.x, .y = ball.y }, ball.radius, paddle)) {
                ball.speed_y *= -1;
                ball.y = paddle.y - ball.radius - 1; // prevent sticking
            }

            // ball out of bounds (bottom)
            if (ball.y + ball.radius >= HEIGHT) {
                // reset ball position
                ball.x = @as(f32, (WIDTH / 2));
                ball.y = paddle.y - paddle.height;
                game_started = false;
            }

            if (rl.IsKeyDown(263)) { // left arrow
                paddle.x -= 5;
            } else if (rl.IsKeyDown(262)) { // right arrow
                paddle.x += 5;
            }
        }
        paddle.x = std.math.clamp(paddle.x, 0, WIDTH - paddle.width);

        rl.ClearBackground(rl.BLACK);
        rl.DrawRectangleRec(paddle, rl.PINK);
        rl.DrawCircleV(rl.Vector2{ .x = ball.x, .y = ball.y }, ball.radius, ball.color); //  ball
        rl.DrawText("Breakout", 300, 100, 80, rl.LIGHTGRAY);
    }
}

test "simpletest" {}
