# Automatic Nipple Detection in Breast Thermograms

This project implements an algorithm for automatic nipple detection in breast thermograms using MATLAB. The method is based on a research paper and aims to identify nipple locations to segment regions of interest from infrared images.

---

## Table of Contents
- [Introduction](#introduction)
- [Features](#features)
- [Algorithm Overview](#algorithm-overview)
  - [1. Human Body Segmentation](#1-human-body-segmentation)
  - [2. Nipple Candidate Detection](#2-nipple-candidate-detection)
  - [3. Nipple Selection](#3-nipple-selection)
- [Results](#results)

---

## Introduction

Nipple detection is a critical step for accurately segmenting regions of interest in breast thermograms. Thermograms provide valuable insights for medical analysis, but precise detection of nipples is essential to isolate relevant areas for further examination. This project implements the proposed algorithm to normalize the input image, detect nipple candidates, select the actual nipples, and plot the results on the image.

---

## Features

- **Automated Body Segmentation**: Binary mask creation and morphological operations.
- **Nipple Candidate Identification**: Using median filtering and thresholding techniques.
- **Nipple Selection**: Based on connected components and geometric properties.
- **Visualization**: Detected nipples plotted directly on the input images.

---

## Algorithm Overview

### 1. Human Body Segmentation
- **Thresholding**: Create a binary human mask by comparing pixel values to a defined threshold.
- **Morphological Operations**:
  - Perform morphological closing using a disk-shaped structuring element.
  - Apply dilation with radii of 3 and 10 to smooth the mask.
- **Mask Application**: Replace mask values in the grayscale image with zeros to refine the segmentation.

### 2. Nipple Candidate Detection
- **Filtering**: Use a median filter with a local neighborhood of 15 and sensitivity of 0.03.
- **Image Subtraction**: Subtract the original image from the filtered one using `imsubtract()`.
- **Thresholding**: Binarize the subtracted image using the `imbinarize()` function with a sensitivity of 0.03.

### 3. Nipple Selection
- **Component Filtering**:
  - Remove small components (<20 pixels) using `bwareaopen()`.
  - Calculate bounding values (e.g., Hup and Hlw) to crop regions of interest.
- **Connected Components**:
  - Identify connected components using `bwconncomp()`.
  - Extract properties like centroid, area, and roundness.
- **Final Selection**:
  - Determine left and right nipples based on X center-line.
  - Select components with maximum roundness and area.
  - Store nipple coordinates for visualization.

---

## Results

The algorithm shows promising results with clear thermographic images. Performance varies depending on nipple visibility and contrast:

- **Accurate Detection**:
  - Images like `IR_0100` and `IR_2841` show precise nipple localization.
- **Challenging Cases**:
  - Images like `IR_1367` have unclear nipples, leading to inaccuracies in detection.
- **Visualization**: Detected nipples are marked on the image using the `insertMarker()` function.

---
