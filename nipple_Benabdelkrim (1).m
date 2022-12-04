
img = imread('./test/IR_4089.png'); %uigetfile doesn't work, ERROR: MAP must be a m x 3 array.
figure, imshow(img)
title('Human Body Image')

segmented_body = human_body_segmentation(img);
figure, imshow(segmented_body)
title('Segmented Human Body Image')

nipple_candidates = determine_nipple_candidates(segmented_body);
figure, imshow(nipple_candidates)
title('Nipple Candidates Image')

selected_nipples = plot_human_selected_nipples(determine_nipples_selection(nipple_candidates),img);
figure, imshow(selected_nipples)
title('Selected Nipples Image')

function segmented_body = human_body_segmentation(img)
    segmented_body = rgb2gray(img); %img to grayscale
    th = 50;
    human_mask = segmented_body < th; %normalize img (pixels > 50 = 1, pixels <= 50 = 0)
    
    %morphological closing, disk-shaped, radius 3
    SE_3 = strel('disk', 3); %https://es.mathworks.com/help/images/ref/strel.html
    close_BW = imclose(human_mask, SE_3);
    %morphological dilation, disk-shaped, radius 10
    SE_10 = strel('disk', 10);
    BW2 = imdilate(close_BW, SE_10); %https://es.mathworks.com/help/images/ref/imdilate.html
    
    segmented_body(BW2) = 0; %set mask to 0 in final image
end


function nipple_candidates = determine_nipple_candidates(img)
    %convolution of the img
    conv_img = medfilt2(img, [15, 15]); %https://es.mathworks.com/help/images/ref/medfilt2.html
    %substraction of the original img
    substraction = imsubtract(conv_img, img); %https://es.mathworks.com/help/images/ref/imsubtract.html
    %create binary img with 0.03 sensitivity
    nipple_candidates = imbinarize(substraction, 0.03); %https://es.mathworks.com/help/images/ref/imbinarize.html
end


function nipple = select_nipple(candidates, side)
    nipple = candidates(1); %only to initalize variable
    if size(side) > 0
        nipple = candidates(side(1)); %init selected nipple
        for i=1:length(side)
            if candidates(side(i)).Circularity > nipple.Circularity
                nipple = candidates(side(i));
            %if roundess equal, then select nipple with higher area
            elseif candidates(side(i)).Circularity == nipple.Circularity
                if candidates(side(i)).Area > nipple.Area
                    nipple = candidates(side(i));
                end
            end
        end
    end
end

function selected_nipples = determine_nipples_selection(img)
    Np = 20;
    BW2 = bwareaopen(img, Np); %https://es.mathworks.com/help/images/ref/bwareaopen.html
    %calculate height and width of thermogram img
    [r, c] = size(BW2);
    Hup = 0.35 * r;
    Hlw = 0.3 * r;
    Lcnt = c/2; %center-line
    %crop img using ((x,y),(x',y')) coordinates to get thermogram img
    new_img = imcrop(BW2,[0 Hlw c Hup]); %https://es.mathworks.com/help/images/ref/imcrop.html
    nipples_candidates = regionprops(bwconncomp(bwareaopen(new_img,Np)),'all'); %get props of https://es.mathworks.com/help/images/ref/bwconncomp.html
    
    left_nipples = [];
    right_nipples = [];
   	%determine left and right nipples using center-line and storing nipple
   	%index
    for i = 1:length(nipples_candidates)
        candidate_centroid = nipples_candidates(i).Centroid(1);
        if  Lcnt < candidate_centroid
            right_nipples(end + 1) = i;
        else
            if  Lcnt > candidate_centroid
                left_nipples(end + 1) = i;
            end
        end
    end
    %select left and right nipple centroids
    selected_nipples.right_nipple = select_nipple(nipples_candidates, right_nipples).Centroid;
    selected_nipples.left_nipple = select_nipple(nipples_candidates, left_nipples).Centroid;
    %store Hlw (to shift nipple mark)
    selected_nipples.Hlw = Hlw;    
end


function img = plot_human_selected_nipples(nipples, img)
    %to plot nipples, use Hlw to shift Y coordinate nipple mark in relation to image
    %calculate coordinates
    nipples.left_nipple(2) = nipples.Hlw + nipples.left_nipple(2);
    nipples.right_nipple(2) = nipples.Hlw + nipples.right_nipple(2);
    %plot marks using calculated coordinates
    img = insertMarker(img, nipples.right_nipple); 
    img = insertMarker(img,nipples.left_nipple); 
end

