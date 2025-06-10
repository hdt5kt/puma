#
B1x = -0.0913
B1y = -0.0594463
B1z = -0.07735
#
B2x = 0.0913
B2y = -0.0594463
B2z = -0.07735
#
B3x = 0.0913
B3y = 0.0594463
B3z = -0.07735
#
B4x = -0.0913
B4y = 0.0594463
B4z = -0.07735
#
T1x = -0.0913
T1y = -0.0594463
T1z = 0.07735
#
T2x = 0.0913
T2y = -0.0594463
T2z = 0.07735
#
T3x = 0.0913
T3y = 0.0594463
T3z = 0.07735
#
T4x = -0.0913
T4y = 0.0594463
T4z = 0.07735
#
[Mesh]
  [mesh0]
    type = FileMeshGenerator
    file = '${meshfile}'
  []
  ### Side nodes
  [bottom]
    type = BoundingBoxNodeSetGenerator
    new_boundary = 'bottom'
    bottom_left = '${fparse B1x-0.00001} ${fparse B1y-0.00001} ${fparse B1z-0.00001}'
    input = mesh0
    top_right = '${fparse B3x+0.00001} ${fparse B3y+0.00001} ${fparse B3z+0.00001}'
  []
  [top]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse T1x-0.00001} ${fparse T1y-0.00001} ${fparse T1z-0.00001}'
    input = bottom
    new_boundary = 'top'
    top_right = '${fparse T3x+0.00001} ${fparse T3y+0.00001} ${fparse T3z+0.00001}'
  []
  [front]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse B1x-0.00001} ${fparse B1y-0.00001} ${fparse B1z-0.00001}'
    input = top
    new_boundary = 'front'
    top_right = '${fparse T2x+0.00001} ${fparse T2y+0.00001} ${fparse T2z+0.00001}'
  []
  [back]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse B4x-0.00001} ${fparse B4y-0.00001} ${fparse B4z-0.00001}'
    input = front
    new_boundary = 'back'
    top_right = '${fparse T3x+0.00001} ${fparse T3y+0.00001} ${fparse T3z+0.00001}'
  []
  [left]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse B1x-0.00001} ${fparse B1y-0.00001} ${fparse B1z-0.00001}'
    input = back
    new_boundary = 'left'
    top_right = '${fparse T4x+0.00001} ${fparse T4y+0.00001} ${fparse T4z+0.00001}'
  []
  [right]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse B2x-0.00001} ${fparse B2y-0.00001} ${fparse B2z-0.00001}'
    input = left
    new_boundary = 'right'
    top_right = '${fparse T3x+0.00001} ${fparse T3y+0.00001} ${fparse T3z+0.00001}'
  []
  [sidesets]
    type = SideSetsFromNodeSetsGenerator
    input = right
  []
  ### BCs nodes
  [B2]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse B2x-0.00001} ${fparse B2y-0.00001} ${fparse B2z-0.00001}'
    input = sidesets
    new_boundary = 'B2'
    top_right = '${fparse B2x+0.00001} ${fparse B2y+0.00001} ${fparse B2z+0.00001}'
  []
  [B1]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse B1x-0.00001} ${fparse B1y-0.00001} ${fparse B1z-0.00001}'
    input = B2
    new_boundary = 'B1'
    top_right = '${fparse B1x+0.00001} ${fparse B1y+0.00001} ${fparse B1z+0.00001}'
  []
  [B3]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse B3x-0.00001} ${fparse B3y-0.00001} ${fparse B3z-0.00001}'
    input = B1
    new_boundary = 'B3'
    top_right = '${fparse B3x+0.00001} ${fparse B3y+0.00001} ${fparse B3z+0.00001}'
  []
  [B4]
    type = BoundingBoxNodeSetGenerator
    bottom_left = '${fparse B4x-0.00001} ${fparse B4y-0.00001} ${fparse B4z-0.00001}'
    input = B3
    new_boundary = 'B4'
    top_right = '${fparse B4x+0.00001} ${fparse B4y+0.00001} ${fparse B4z+0.00001}'
  []
[]