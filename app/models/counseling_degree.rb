class CounselingDegree < ActiveRecord::Base
  belongs_to :counselor

  def self.degree_types
    [
      [ 'A.S.',  'Associate of Science' ],
      [ 'A.A.',  'Associate of Arts' ],
      [ 'B.S.',  'Bachelor of Science' ],
      [ 'B.A.',  'Bachelor of Arts' ],
      [ 'M.S.',  'Master of Science' ],
      [ 'M.A.',  'Master of Arts' ],
      [ 'Ph.D.', 'Doctor of Philosophy' ],
      [ 'M.D.',  'Doctor of Medicine' ],
    ]
  end
end
