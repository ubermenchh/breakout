const std = @import("std");
const rl = @cImport({
    @cInclude("raylib.h");
});

const BALL = struct {
    x: f32,
    y: f32,
    speed_x: f32,
    speed_y: f32,
    radius: f32,
    color: rl.Color,
};
const BRICK = struct { rect: rl.Rectangle, color: rl.Color, active: bool };

const WIDTH: i16 = 1024; // screen width
const HEIGHT: i16 = 1024; // screen height
const ROWS = 7; // no of rows of bricks
const COLS = 10; // no of columns of bricks
const BRICK_WIDTH = WIDTH / COLS; // brick width
const BRICK_HEIGHT = 30; // brick height
const DEFAULT_LIVES = 3;

pub fn main() !void {
    var paddle = rl.Rectangle{ .x = 462, .y = 900, .height = 10, .width = 100 };
    var ball = BALL{ .x = @as(f32, WIDTH / 2), .y = paddle.y - paddle.height, .speed_x = 5, .speed_y = -5, .radius = 5, .color = rl.BLUE };

    var game_started = false;
    var game_paused = false;
    var game_won = false;
    var game_over = false;

    var bricks: [ROWS][COLS]BRICK = undefined;
    for (0..ROWS) |row| {
        for (0..COLS) |col| {
            bricks[row][col] = BRICK{
                .rect = rl.Rectangle{ .x = @as(f32, @floatFromInt(col)) * BRICK_WIDTH, .y = @as(f32, @floatFromInt(row)) * BRICK_HEIGHT + 100, .width = BRICK_WIDTH, .height = BRICK_HEIGHT },
                .color = rl.ColorFromHSV(@as(f32, @floatFromInt(row)) * 40, 0.8, 0.8),
                .active = true,
            };
        }
    }
    var score: i32 = 0;
    var score_text: [20]u8 = undefined;
    var lives_remaining: i32 = DEFAULT_LIVES;

    rl.InitWindow(1024, 1024, "Breakout");
    defer rl.CloseWindow();
    rl.SetTargetFPS(60);

    while (!rl.WindowShouldClose()) {
        //const key_pressed: c_int = rl.GetKeyPressed();
        //if (key_pressed != 0) {
        //    std.debug.print("key: {d}\n", .{key_pressed});
        //}

        if (rl.IsKeyPressed(rl.KEY_P))
            game_paused = !game_paused;

        if (!game_paused) {
            if (rl.IsKeyReleased(rl.KEY_SPACE)) {
                game_started = true;
                game_over = false;
            }

            if (score == ROWS * COLS) {
                game_won = true;
                game_started = false;
            }
            if (lives_remaining == -1) {
                game_over = true;
                game_started = false;
            }

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

                // ball collision with bricks
                for (0..ROWS) |row| {
                    for (0..COLS) |col| {
                        if (bricks[row][col].active) {
                            if (rl.CheckCollisionCircleRec(rl.Vector2{ .x = ball.x, .y = ball.y }, ball.radius, bricks[row][col].rect)) {
                                bricks[row][col].active = false;
                                ball.speed_y *= -1;
                                score += 1;
                            }
                        }
                    }
                }

                // ball out of bounds (bottom)
                if (ball.y + ball.radius >= HEIGHT or game_paused) {
                    // reset ball position
                    ball.x = @as(f32, (WIDTH / 2));
                    ball.y = paddle.y - paddle.height;

                    // reset paddle position
                    paddle.x = 462;
                    paddle.y = 900;

                    game_started = false;
                    lives_remaining -= 1;
                }

                if (rl.IsKeyDown(rl.KEY_LEFT)) { // left arrow
                    paddle.x -= 7;
                } else if (rl.IsKeyDown(rl.KEY_RIGHT)) { // right arrow
                    paddle.x += 7;
                }
            }
            paddle.x = std.math.clamp(paddle.x, 0, WIDTH - paddle.width);
        }

        // draw
        rl.BeginDrawing();
        defer rl.EndDrawing();

        rl.ClearBackground(rl.BLACK);

        // draw bricks
        for (0..ROWS) |row| {
            for (0..COLS) |col| {
                if (bricks[row][col].active) {
                    rl.DrawRectangleRec(bricks[row][col].rect, bricks[row][col].color);
                }
            }
        }

        rl.DrawRectangleRec(paddle, rl.PINK);
        rl.DrawCircleV(rl.Vector2{ .x = ball.x, .y = ball.y }, ball.radius, ball.color); //  ball
        rl.DrawText("Score: ", 10, 10, 30, rl.LIGHTGRAY);
        _ = std.fmt.bufPrintZ(&score_text, "{d}", .{score}) catch unreachable;
        if (score == 69)
            rl.DrawText("Nice!", 150, 20, 30, rl.LIGHTGRAY);
        rl.DrawText(&score_text, 120, 10, 30, rl.LIGHTGRAY);

        var life: i32 = 0;
        while (life < lives_remaining) : (life += 1) {
            rl.DrawRectangle(10 + (life * 20), HEIGHT - 10, 15, 5, rl.PINK);
        }

        if (!game_started and !game_over) {
            rl.DrawText("Breakout", 350, WIDTH / 2, 80, rl.LIGHTGRAY);
            rl.DrawText("Press <SPACE> to start.", WIDTH / 2 - 112, HEIGHT / 2 + 100, 20, rl.LIGHTGRAY);
        }
        if (game_paused and game_started) {
            rl.DrawText("Game Paused!", WIDTH / 2 - 250, HEIGHT / 2, 80, rl.LIGHTGRAY);
            rl.DrawText("Press <P> to resume.", WIDTH / 2 - 110, HEIGHT / 2 + 100, 20, rl.LIGHTGRAY);
        }

        if (game_won and !game_started) {
            rl.DrawText("Yay! You Won!", 350, HEIGHT / 2, 80, rl.LIGHTGRAY);
        }

        if (game_over) {
            rl.DrawText("Better Luck Next Time!", 40, HEIGHT / 2, 80, rl.LIGHTGRAY);
            rl.DrawText("Press <SPACE> to restart.", WIDTH / 2 - 110, HEIGHT / 2 + 100, 20, rl.LIGHTGRAY);
        }
    }
}

test "simpletest" {}
