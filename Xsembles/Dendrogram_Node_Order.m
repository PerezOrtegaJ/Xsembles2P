function dendrogram_order = Dendrogram_Node_Order(tree)
    % Get the dendrogram order from a given tree
    %
    %   dendrogram_order = Dendrogram_Node_Order(tree)
    %
    % Based on dendrogram.m 
    % Modified by Jesus Perez-Ortega, Sep 2023
    
    % Translate tree
    tree = transz(tree);

    % Sort tree
    dendrogram_order = orderTree(tree);
end


% Tree functions
function Z = transz(Z)
    %TRANSZ Translate output of LINKAGE into another format.
    %   This is a helper function used by DENDROGRAM and COPHENET.
    %   For each node currently labeled numLeaves+k, replace its index by
    %   min(i,j) where i and j are the nodes under node numLeaves+k.

    %   In LINKAGE, when a new cluster is formed from cluster i & j, it is
    %   easier for the latter computation to name the newly formed cluster
    %   min(i,j). However, this definition makes it hard to understand
    %   the linkage information. We choose to give the newly formed
    %   cluster a cluster index M+k, where M is the number of original
    %   observation, and k means that this new cluster is the kth cluster
    %   to be formed. This helper function converts the M+k indexing into
    %   min(i,j) indexing.

    n_leaves = size(Z,1)+1;

    for i = 1:(n_leaves - 1)
        if Z(i, 1) > n_leaves
            Z(i, 1) = traceback(Z, Z(i, 1));
        end

        if Z(i, 2) > n_leaves
            Z(i, 2) = traceback(Z, Z(i, 2));
        end

        if Z(i, 1) > Z(i, 2)
            Z(i, 1:2) = Z(i, [2 1]);
        end
    end
end
function a = traceback(Z, b)
    n_leaves = size(Z, 1) + 1;

    if Z(b - n_leaves, 1) > n_leaves
        a = traceback(Z, Z(b - n_leaves, 1));
    else
        a = Z(b - n_leaves, 1);
    end

    if Z(b - n_leaves, 2) > n_leaves
        c = traceback(Z, Z(b - n_leaves, 2));
    else
        c = Z(b - n_leaves, 2);
    end

    a = min(a, c);
end

function perm = orderTree(tree)
    n_leaves = size(tree,1)+1;
    r = zeros(n_leaves, 1);
    W = arrangeZIntoW(n_leaves, tree);
    perm = fillXFromW(n_leaves, W, r);
end
function W = arrangeZIntoW(n_leaves, tree) % to remove crossing
    W = zeros(size(tree));
    W(1, :) = tree(1, :);
    nsw = zeros(n_leaves, 1);
    rsw = nsw;
    nsw(tree(1, 1:2)) = 1;
    rsw(1) = 1;
    k = 2; s = 2;
    while (k < n_leaves)
        i = s;
        while rsw(i) ||~any(nsw(tree(i, 1:2)))

            if rsw(i) && i == s
                s = s + 1;
            end

            i = i + 1;
        end
        W(k, :) = tree(i, :);
        nsw(tree(i, 1:2)) = 1;
        rsw(i) = 1;

        if s == i
            s = s + 1;
        end
        k = k + 1;
    end
end
function perm = fillXFromW(n_leaves, W, r)
    X = 1:n_leaves; %the initial points for observation 1:n
    g = 1;

    for k = 1:n_leaves - 1
        i = W(k, 1); % the left node in W(k,:)

        if ~r(i)
            X(i) = g;
            g = g + 1;
            r(i) = 1;
        end

        i = W(k, 2); % the right node in W(k,:)

        if ~r(i)
            X(i) = g;
            g = g + 1;
            r(i) = 1;
        end
    end
    perm(X) = 1:n_leaves;
end
