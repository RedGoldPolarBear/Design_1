/*
 * Copyright (c) 2026 Lauren McDonald
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module tt_um_vga_example(
  input  wire [7:0] ui_in,    // Dedicated inputs
  output wire [7:0] uo_out,   // Dedicated outputs
  input  wire [7:0] uio_in,   // IOs: Input path
  output wire [7:0] uio_out,  // IOs: Output path
  output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
  input  wire       ena,      // always 1 when the design is powered, so you can ignore it
  input  wire       clk,      // clock
  input  wire       rst_n     // reset_n - low to reset
);

  // VGA signals
  wire hsync;
  wire vsync;
  wire [1:0] R;
  wire [1:0] G;
  wire [1:0] B;
  wire video_active;
  wire [9:0] pix_x;
  wire [9:0] pix_y;

  // TinyVGA PMOD
  assign uo_out = {hsync, B[0], G[0], R[0], vsync, B[1], G[1], R[1]};

  // Unused outputs
  assign uio_out = 0;
  assign uio_oe  = 0;

  // Suppress unused warnings
  wire _unused_ok = &{ena, ui_in, uio_in};

  reg [9:0] counter;

  hvsync_generator hvsync_gen(
    .clk(clk),
    .reset(~rst_n),
    .hsync(hsync),
    .vsync(vsync),
    .display_on(video_active),
    .hpos(pix_x),
    .vpos(pix_y)
  );

  // Vertical motion
  wire [9:0] moving_y = pix_y + counter;

  // This controls the small horizontal stripes that move upward
  wire stripe = moving_y[2];

  // Irish flag thirds
  wire left_third   = (pix_x < 10'd213);
  wire middle_third = (pix_x >= 10'd213) && (pix_x < 10'd426);
  wire right_third  = (pix_x >= 10'd426);

  // Green band: two bright green shades
  wire [1:0] R_left = 2'b00;
  wire [1:0] G_left = stripe ? 2'b11 : 2'b10;
  wire [1:0] B_left = 2'b00;

  // White band: white / gray stripes
  wire [1:0] R_mid = stripe ? 2'b11 : 2'b10;
  wire [1:0] G_mid = stripe ? 2'b11 : 2'b10;
  wire [1:0] B_mid = stripe ? 2'b11 : 2'b10;

  // Orange band: two orange shades, not yellow
  wire [1:0] R_right = 2'b11;
  wire [1:0] G_right = stripe ? 2'b01 : 2'b10;
  wire [1:0] B_right = 2'b00;

  assign R = video_active ?
             (left_third   ? R_left  :
              middle_third ? R_mid   :
                             R_right) : 2'b00;

  assign G = video_active ?
             (left_third   ? G_left  :
              middle_third ? G_mid   :
                             G_right) : 2'b00;

  assign B = video_active ?
             (left_third   ? B_left  :
              middle_third ? B_mid   :
                             B_right) : 2'b00;

  always @(posedge vsync, negedge rst_n) begin
    if (~rst_n) begin
      counter <= 0;
    end else begin
      counter <= counter + 1;
    end
  end

  wire _unused_ok_ = &{moving_y, right_third};

endmodule
