% % % % By Shireen Fathy
% % % % This shows how to see a target from a point on Earth

function simple_topocentric_demo()
% % %  User Inputs 
fprintf(" Shireen please enter the data \n")
    lat = input('Enter latitude (deg): ');   %latitude on Earth
    lon = input('Enter longitude (deg): '); % longitude on Earth
    h   = input('Enter altitude (m): ');  % height from sea level
    A   = input('Azimuth (deg): ');  % which direction is the target (0=N,90=E)
    el  = input('Elevation (deg): ');  % how high is the target in the sky
    rng = input('Range (m): '); % distance to the target
% % % Earth Parameters
    Re = 6378137;  % radius of Earth in meters 
    f  = 1/298.257;    % how squished is the Earth (flattening)
% % % Compute Positions
    R_ecef   = geodetic2ecef(lat, lon, h, Re, f);  % my position in 3D space
    rho_ecef = azelrange2ecef(A, el, rng, lat, lon);   % target vector from me
    r_ecef   = R_ecef + rho_ecef; % target absolute position
% % % %  Plotting 
    figure; hold on; grid on; axis equal;
    scale = 1/50;
    Re_vis = Re*scale;   % shrink everything to see it better

% --- Plot Earth as a sphere ---
    [Xe,Ye,Ze] = sphere(50);
    mesh(Re_vis*Xe, Re_vis*Ye, Re_vis*Ze, ...
        'EdgeColor',[0.3 0.3 0.8], 'FaceAlpha',0); % just the outline, looks like a globe
% --- Plot a simple circular orbit for fun ---
    theta = linspace(0,2*pi,200);
    r_orbit = (Re+700e3)*scale; % 700 km above Earth
    plot3(r_orbit*cos(theta), r_orbit*sin(theta), zeros(size(theta)),'r--','LineWidth',2);

% --- Plot me and the target ---
    plot3(R_ecef(1)*scale,R_ecef(2)*scale,R_ecef(3)*scale,'ko','MarkerSize',8,'LineWidth',2); % me = black dot
    plot3(r_ecef(1)*scale,r_ecef(2)*scale,r_ecef(3)*scale,'rx','MarkerSize',12,'LineWidth',2); % target = red X

    % --- Draw line from me to the target ---
    plot3([R_ecef(1) r_ecef(1)]*scale, ...
          [R_ecef(2) r_ecef(2)]*scale, ...
          [R_ecef(3) r_ecef(3)]*scale,'k-','LineWidth',2); % my line of sight

 % Labels and Title 
    xlabel('X [m]'); ylabel('Y [m]'); zlabel('Z [m]'); % axes labels
    title(' Topocentric Demo '); % fun title
    legend('Earth','Reference Orbit','Observer','Target','Line of Sight','Location','best');

    view(40,25); % nice angle to see everything
end

% % % % % % %  Helper Functions
function R_ecef = geodetic2ecef(phi, lambda, H, Re, f)
    % this function convert lat/lon/alt to X,Y,Z (ECEF)
    phi = deg2rad(phi); lambda = deg2rad(lambda);
    e2 = f*(2-f);
    N = Re ./ sqrt(1 - e2*sin(phi).^2);
    X = (N+H).*cos(phi).*cos(lambda);
    Y = (N+H).*cos(phi).*sin(lambda);
    Z = (N*(1-e2)+H).*sin(phi);
    R_ecef = [X;Y;Z]; % return as a column vector
end

function rho_ecef = azelrange2ecef(A, el, rng, phi, lambda)
    % this function convert azimuth/elevation/range to a 3D vector in ECEF
    A=deg2rad(A); el=deg2rad(el); phi=deg2rad(phi); lambda=deg2rad(lambda);
    E = rng*cos(el).*sin(A);
    N = rng*cos(el).*cos(A);
    U = rng*sin(el);
    sL=sin(lambda); cL=cos(lambda); sP=sin(phi); cP=cos(phi);
    T=[-sL cL 0; -sP*cL -sP*sL cP; cP*cL cP*sL sP];
    rho_ecef=T*[E;N;U]; % final vector from observer to target
end
