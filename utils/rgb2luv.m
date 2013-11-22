function [ luv ] = rgb2luv( rgb)

luv  = colorspace('rgb->luv', rgb);