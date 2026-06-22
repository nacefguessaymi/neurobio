%Mouse Brain Clean and Mesh Construction

close all
p = gcp('nocreate'); % If no pool, do not create new one.
if isempty(p)
    poolsize = 0;
    parpool
else
    poolsize = p.NumWorkers;
end

%Open the stl file
stl_file = fullfile('Users','Nacef','Library','CloudStorage','GoogleDrive-nguessay@andrew.cmu.edu','My Drive','Parylene_Photonics','Insertion Optomization','Mouse_Brain_Cast','Mouse_Brain_Scaled v2.stl');
brain = readSurfaceMesh(stl_file);

% Example usage with your mesh
brain_cleaned = removeIsolatedVertices(brain);

% Verify the cleaned mesh
surfaceMeshShow(brain_cleaned,Title="Input Mesh");


%Laplacian Smoothing Smoothed Brain 
numIterations = [10 20 50 100 200 500 1000];
laplace_smooth_brain_struct = struct('mesh', cell(1, numel(numIterations)),"numIterations",0); % Initialize struct array
avg_smooth_brain_struct = struct('mesh', cell(1, numel(numIterations)),"numIterations",0); % Initialize struct array
hc_smooth_brain_struct = struct('mesh', cell(1, numel(numIterations)),"numIterations",0); % Initialize struct array

parfor i = 1:numel(numIterations)
    laplace_smooth_brain_struct(i).numIterations=numIterations(i);
    laplace_smooth_brain_struct(i).mesh = smoothSurfaceMesh(brain_cleaned, numIterations(i), 'Method', "Laplacian");
    avg_smooth_brain_struct(i).numIterations=numIterations(i);
    avg_smooth_brain_struct(i).mesh = smoothSurfaceMesh(brain_cleaned, numIterations(i));
    hc_smooth_brain_struct(i).numIterations=numIterations(i);
    hc_smooth_brain_struct(i).mesh = smoothSurfaceMesh(brain_cleaned, numIterations(i), 'Method', "Laplacian");
end

%Plots with titles
% for i = 1:numel(numIterations)
%     surfaceMeshShow(smooth_brain_struct(i).mesh,Title="Laplacian Filter (Number of Iterations = "+numIterations(i)+")")
% end
% writeSurfaceMesh(final_smooth_brain,"Mouse_Brain_Smoothed.stl");

function cleanedMesh = removeIsolatedVertices(mesh)
    % Extract vertices and faces from the input mesh
    vertices = mesh.Vertices;
    faces = mesh.Faces;

    % Find unique vertex indices used in faces
    usedVertices = unique(faces(:));

    % Create a mapping from old vertex indices to new ones
    newIndexMap = zeros(size(vertices, 1), 1);
    newIndexMap(usedVertices) = 1:length(usedVertices);

    % Apply the mapping to faces
    newFaces = newIndexMap(faces);

    % Extract the used vertices
    newVertices = vertices(usedVertices, :);

    % Create the cleaned mesh
    cleanedMesh = surfaceMesh(newVertices, newFaces);
end
