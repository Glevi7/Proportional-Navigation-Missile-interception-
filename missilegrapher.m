

% Extract data from simulink model 
if isa(out.missile_pos, 'timeseries')
    missile_data = out.missile_pos.Data;
    target_data = out.target_pos.Data;
    missile_rot_data = out.missile_rot.Data;
    target_rot_data = out.target_rot.Data;
else
    missile_data = out.missile_pos;
    target_data = out.target_pos;
    missile_rot_data = out.missile_rot;
    target_rot_data = out.target_rot;
end


% Create figure
figure('Position', [100, 100, 1400, 1000], 'Color', [0.15 0.15 0.15]);
ax = axes('Color', [0.1 0.1 0.1], 'XColor', 'w', 'YColor', 'w', 'ZColor', 'w');
hold on;
grid on;
box on;

% 3D axis labels
xlabel('X Position (m)', 'FontSize', 14, 'Color', 'w', 'FontWeight', 'bold');
ylabel('Y Position (m)', 'FontSize', 14, 'Color', 'w', 'FontWeight', 'bold');
zlabel('Z Position (m)', 'FontSize', 14, 'Color', 'w', 'FontWeight', 'bold');
title('Missile Tracking Target - 3D Trajectory', 'FontSize', 16, 'Color', 'w', 'FontWeight', 'bold');

%orient view
view(3); 
camproj('orthographic');  

daspect([1 1 1]);

% Enable 3D rotation
rotate3d on;

% Initialize trail arrays
missile_trail_x = [];
missile_trail_y = [];
missile_trail_z = [];
target_trail_x = [];
target_trail_y = [];
target_trail_z = [];

% Create plot objects
missile_trail = plot3(0, 0, 0, 'r-', 'LineWidth', 3);
target_trail = plot3(0, 0, 0, 'b-', 'LineWidth', 3);

% Markers
missile_marker = plot3(0, 0, 0, 'o', 'MarkerSize', 20, 'MarkerFaceColor', [1 0.3 0.3],'MarkerEdgeColor', [1 1 1], 'LineWidth', 2);
target_marker = plot3(0, 0, 0, 's', 'MarkerSize', 22, 'MarkerFaceColor', [0.3 0.5 1], 'MarkerEdgeColor', [1 1 1], 'LineWidth', 2);

% arrow
arrow_shaft = plot3([0 0], [0 0], [0 0], 'Color', [1 1 0], 'LineWidth', 4);
arrow_head = patch('XData', [], 'YData', [], 'ZData', [],'FaceColor', [1 1 0], 'EdgeColor', [1 1 0], 'LineWidth', 2);

legend('Missile Trail', 'Target Trail', 'Missile', 'Target', 'Direction to Target','Location', 'northeast', 'TextColor', 'w', 'Color', [0.2 0.2 0.2]);


skip = max(1, floor(n_frames/500));



frame_indices = 1:skip:n_frames;
if frame_indices(end) ~= n_frames
    frame_indices = [frame_indices, n_frames];
end

for idx = 1:length(frame_indices)
    i = frame_indices(idx);
    
    % Extract positions
    missile_x = missile_data(i, 1);
    missile_y = missile_data(i, 2);
    missile_z = missile_data(i, 3);
    
    target_x = target_data(i, 1);
    target_y = target_data(i, 2);
    target_z = target_data(i, 3);
    
    % Build trails
    missile_trail_x(end+1) = missile_x;
    missile_trail_y(end+1) = missile_y;
    missile_trail_z(end+1) = missile_z;
    
    target_trail_x(end+1) = target_x;
    target_trail_y(end+1) = target_y;
    target_trail_z(end+1) = target_z;
    
    % Update trails
    set(missile_trail, 'XData', missile_trail_x,'YData', missile_trail_y,'ZData', missile_trail_z);
    
    set(target_trail, 'XData', target_trail_x,'YData', target_trail_y,'ZData', target_trail_z);
    
    % Update markers
    set(missile_marker, 'XData', missile_x, 'YData', missile_y,'ZData', missile_z);
    
    set(target_marker, 'XData', target_x, 'YData', target_y, 'ZData', target_z);
    
    dx_to_target = target_x - missile_x;
    dy_to_target = target_y - missile_y;
    dz_to_target = target_z - missile_z;
    
    distance_full = sqrt(dx_to_target^2 + dy_to_target^2 + dz_to_target^2);
    
    % Arrow length
    arrow_length = distance_full * 0.5;
    

%arrow animation 
    if distance_full > 0.1
        arrow_dx = (dx_to_target / distance_full) * arrow_length;
        arrow_dy = (dy_to_target / distance_full) * arrow_length;
        arrow_dz = (dz_to_target / distance_full) * arrow_length;
        
        
        tip_x = missile_x + arrow_dx;
        tip_y = missile_y + arrow_dy;
        tip_z = missile_z + arrow_dz;
        
        set(arrow_shaft, 'XData', [missile_x, tip_x], 'YData', [missile_y, tip_y], 'ZData', [missile_z, tip_z]);
        
        head_size = arrow_length * 0.15;
        
       
        perp_x = -dz_to_target;
        perp_z = dx_to_target;
        perp_norm = sqrt(perp_x^2 + perp_z^2);
        
        if perp_norm > 0.01
            perp_x = perp_x / perp_norm * head_size;
            perp_z = perp_z / perp_norm * head_size;
        else
            perp_x = head_size;
            perp_z = 0;
        end
        
        back_ratio = 0.85;
        back_x = missile_x + arrow_dx * back_ratio;
        back_y = missile_y + arrow_dy * back_ratio;
        back_z = missile_z + arrow_dz * back_ratio;
        
        head_x = [tip_x, back_x + perp_x, back_x - perp_x, tip_x];
        head_y = [tip_y, back_y, back_y, tip_y];
        head_z = [tip_z, back_z + perp_z, back_z - perp_z, tip_z];
        
        set(arrow_head, 'XData', head_x, 'YData', head_y, 'ZData', head_z);
    else
        set(arrow_shaft, 'XData', [], 'YData', [], 'ZData', []);
        set(arrow_head, 'XData', [], 'YData', [], 'ZData', []);
    end
    
    all_x = [missile_trail_x, target_trail_x];
    all_y = [missile_trail_y, target_trail_y];
    all_z = [missile_trail_z, target_trail_z];
    
    if ~isempty(all_x)
        x_range = max(all_x) - min(all_x);
        y_range = max(all_y) - min(all_y);
        z_range = max(all_z) - min(all_z);
        
        if y_range < 1
            y_center = mean(all_y);
            y_range = max(x_range, z_range) * 0.3;
            ylim([y_center - y_range/2, y_center + y_range/2]);
        else
            ylim([min(all_y)-5, max(all_y)+5]);
        end
        
xlim([min(all_x)-1000, max(all_x)+2500]);
zlim([min(all_z)-20, max(all_z)+20]);
    end
    
    pbaspect([1 1 1]);
    
    % live update title
    title(sprintf('Missile Tracking Target - Frame %d/%d (%.1f%%) | Distance: %.1fm', i, n_frames, 100*i/n_frames, distance_full),'FontSize', 14, 'Color', 'w', 'FontWeight', 'bold');
    
    pause(0.001);
    drawnow;
end