clear all;
test_list_file='/home/ubuntu/data/test_mlocr.txt';
img_dir = '/home/ubuntu/data/test_images/';
gt_dir= '/home/ubuntu/data/test_xml/result_60000/';
% multi-scale detection results directory
dt_dir = '/home/ubuntu/data/multi_scale_result/';
% save results to upload to ICDAR 2015 website
icdar_test_dir='/home/ubuntu/data/multi_scale_result_upload/';

javaaddpath ("/Users/panks/Dropbox/silversparro/xerces-2_11_0/xercesImpl.jar");
javaaddpath ("/Users/panks/Dropbox/silversparro/xerces-2_11_0/xml-apis.jar");

[img_name]=textread(test_list_file,'%s');
%settings
info.iou_thr = 0.5;
nImg=length(img_name)
gt = cell(nImg,1);
dt = cell(nImg,1);
box_num=0;
for ii=1:nImg
    name = img_name(ii);
    name=char(name);
    img=imread([img_dir,name,'.jpg']);
    [img_height,img_width,~]=size(img);
    gt_path = [ gt_dir,'gt_',name(1:end-3),'.xml'];

    parser = javaObject('org.apache.xerces.parsers.DOMParser');
    parser.parse(gt_path); % it seems that cd in octave are taken into account
    xDoc = parser.getDocument;

    % get first data element
    bndbox = xDoc.getElementsByTagName('annotation').item(0).getElementsByTagName('object').item(0).getElementsByTagName('bndbox').item(0);
    x1 = bndbox.getElementsByTagName('xmin').item(0).getFirstChild.getTextContent
    y1 = bndbox.getElementsByTagName('ymin').item(0).getFirstChild.getTextContent
    x3 = bndbox.getElementsByTagName('xmax').item(0).getFirstChild.getTextContent
    y3 = bndbox.getElementsByTagName('ymax').item(0).getFirstChild.getTextContent
    disp(["xml data",x1,y1,x3,y3]);

    x2=x3;
    y2=y1;
    x4=x1;
    y4=y3;
    bbs_gt = [x1,y1,x2,y2,x3,y3,x4,y4];

    gt{ii}=bbs_gt;
    %dt
    dt_path = [dt_dir,name(1:end-3),'txt'];
    [x1,y1,x2,y2,x3,y3,x4,y4,score,size_num]=textread(dt_path,'%d %d %d %d %d %d %d %d %f %d');
    bbs_dt = [x1,y1,x2,y2,x3,y3,x4,y4];

    nms_flag=nms(bbs_dt',score,'overlap',0.25);
    bbs_dt=bbs_dt(nms_flag==true,:);
    score=score(nms_flag==true,:);
    bbs_dt=bbs_dt(score>0.9,:);

    % for jj = 1 : size(bbs_dt, 1)
    %     % colors = randi(255, 1, 3);
    %     colors = [124,252,0];
    %     img = insertShape(img, 'Polygon', int32(bbs_dt(jj,:)), 'Color', colors,'LineWidth',5);
    %     % text_str = score(jj);

    %     % start_point_x = min([bbs_dt(jj,1), bbs_dt(jj,3), bbs_dt(jj,5), bbs_dt(jj,7)]);
    %     % start_point_y = min([bbs_dt(jj,2), bbs_dt(jj,4), bbs_dt(jj,6), bbs_dt(jj,8)]);
    %     % img = insertText(img, [start_point_x, start_point_y], text_str, 'AnchorPoint', 'LeftBottom', 'TextColor', 'red', 'FontSize', 8);
    % end
    % imgSavedPath=[visu_save_dir,name];
    % imwrite(img, imgSavedPath);
  
    icdar_submit_path=[icdar_test_dir,'res_',name(1:end-3),'txt'];
    fid=fopen(icdar_submit_path,'wt');
    for jj=1:size(bbs_dt,1)
        fprintf(fid,'%d,%d,%d,%d\r\n',max(1,bbs_dt(jj,1)),max(1,bbs_dt(jj,2)),min(img_width-1,bbs_dt(jj,5)),min(img_height-1,bbs_dt(jj,6)));
    end
    fclose(fid);
    dt{ii}=double(bbs_dt);
end

%computation p,r,f-measure
detection_count = 0;
gt_count = 0;
hit_recall = 0;
hit_precision=0;
for ii=1:nImg
    bbs_dt = dt{ii};
    if(~isempty(bbs_dt))
        flag_strick = zeros(size(bbs_dt,1), 1);
        for j=1:size(gt{ii},1)
            for i=1:size(bbs_dt,1)
                x_union = [bbs_dt(i,1:2:8),gt{ii}(j,1:2:8)];
                y_union = [bbs_dt(i,2:2:8),gt{ii}(j,2:2:8)];
                union_poly_ind = convhull(x_union, y_union);
                union_area = polyarea(x_union(union_poly_ind), y_union(union_poly_ind));
                insect_area = polygon_intersect(bbs_dt(i,1:2:8),bbs_dt(i,2:2:8), ...
                                     gt{ii}(j,1:2:8), gt{ii}(j,2:2:8));
                flag_strick(i) = ((insect_area / union_area) > info.iou_thr);
            end
            if(sum(flag_strick) > 0)
                    hit_recall = hit_recall + 1;
                    hit_precision=hit_precision+1;
            end 
        end
        detection_count = detection_count + size(bbs_dt,1);
        gt_count = gt_count + size(gt{ii},1);
    else
        gt_count = gt_count + size(gt{ii},1);
    end
end
recall =  hit_recall / gt_count;
precision = hit_precision / detection_count;
f_measure = 2 * recall * precision / (recall + precision)

disp('over!');

