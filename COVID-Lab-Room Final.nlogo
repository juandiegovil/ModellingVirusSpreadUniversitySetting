;;;;;;;;;;;;;;;;;;;;;;;;
;;;VARIABLES & BREEDS;;;------------------------------------------------------------------------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;;;;

globals [
  column-space        ;; Space between the columns of the labs
  row-space           ;; Space between the rows of the labs
  num-chairs          ;; The number of chairs in the lab
  chairs-per-side     ;; The number of chairs per side
  hour                ;; Hours that have passed since program started
  minute              ;; Minutes that have passed since program started
  time                ;; Hours and minutes together
  pathways-xcor       ;; A list containing the xcor of each pathway between the lab columns
  extra               ;; Extra space between the column pathways
  seated              ;; Count of students in their chair
  first-time?         ;; Used for loop purposes (if statements that should only be run through once)
  z                   ;; Count to indicate which demonstration we're on (increases 1 after every demonstration
  dem-labs            ;; List containing the labs used for demonstration in order
  m                   ;; Count to indicate which position in dem-labs list is the lab each intructor will go to (increases 1 after every instructor)
  tables-per-section  ;; List containing the number of tables per each "section" of the room divided for different experiments. Ex: [4 4 4 3] (15 tables, 4 sections)
  time-per-section    ;; How much time in ticks for each experiment section of the lab
  tables-per-groups   ;; Same as tables-per-section but for groups to see different demonstrations
  demonstrations      ;; Has the greater of total number of demonstrations or number of groups to move from demonstration to demonstration i.e how many time an instructor will demonstrate 1 part of the lab
  demonstration?      ;; True if there are demonstrations to show
  avg-contact         ;; Average number of people in contact with per person
  avg-contact-seconds ;; Average number of seconds a student is in contact per person
]

breed [students student]
breed [instructors instructor]

undirected-link-breed [blue-links blue-link] ;; Blue links are used for groups of friends
undirected-link-breed [red-links red-link]   ;; Red links are used for distances for COVID contagion purposes

students-own [
  s-paired?         ;; Paired with a chair? True if yes
  chair-num         ;; Chair number for the student
  clear1?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  clear2?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  clear3?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  clear4?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  clear5?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  steps             ;; Contains the amount of steps remaining to take for a certain part of movement
  waiting           ;; Waiting time to enter the room
  clear?            ;; True if social-radius is clear
  question?         ;; True if the student wants to ask a question
  attended?         ;; True if the question has been attended
  next-question     ;; Waiting time to ask another question (students usually don't have back to back questions)
  pathway-x         ;; Contains which column pathway it is going to take for the question i.e 0 for 1st column of labs 1 for 2nd column of labs
  target            ;; Used as a target to where the instructor / ta wants to go next
  target-patch      ;; Target patch of the chair
  avoiding?         ;; True when students is avoiding the lab table or other students around the lab table
  avoidances        ;; Used to count the amount of times students have changed direction in order to avoid the lab table
  extra-movement?   ;; True for students that are in a hallway where their lab table isn't at during the demonstration. They therefore need to make an extra movement
  friends?          ;; True id the student has a group of friends who he walks with and sits with
  follower?         ;; True if its part of a group and it follows the person in front. One person in a group will have this set to false
  following         ;; Has the student it's following
  num-in-group      ;; Number of people in the group
  follow-position   ;; What position it'll walk in relative to the student it's following. -1 is on its left, -1 on its right, 3 right behind it, -2 behind it and left of it, 2 behind it and right of it
  positions-list    ;; Contains the list of positions a student can follow it in ([-1 1 3 -2 2])
  location          ;; location it's chair is on relative to the lab table. 3 for top row, 2 for extra-seat on the side, 1 for bottom row
  first?            ;; Used for loop purposes (if statements that should only be run through once)
  change-seat?      ;; True if student needs to change seat to do a different section of the lab material
  offset-number     ;; Offset to z, used to find the lab number the particular student should go to for a demonstration
  dem-lab-number-s  ;; Current demonstration lab number to go to, 99 if no lab / demonstration at the moment
  prev-lab-number-s ;; Previous demonstration lab number
  contact-tracing   ;; List containting the amount of seconds student is in contact with all other persons. List is the size of the amount of turtles
  contacts          ;; List of the who of the turtles the student has been in contact with, in order from most length contact to least lengthy contact
  contacts-shorted  ;; Same as contacts list but removes the contacts that lasted less than 5 seconds
  ticks-in-contact  ;; Like the contact-tracing list but in ticks rather than seconds
  ticks-in-contact-order  ;; Same as contact-tracing list but the elements are in order from greatest amount of seconds to least amount of seconds
  avg-ticks         ;; Average ticks student is in contact with other persons
  infected?         ;; True if the student is infected, false otherwise
  presympt          ;; True if the student will be presymptomatic (not showing symptoms), false otherwise
  sympt             ;; True if the student will be symptomatic (showing symptoms), false otherwise
  presympt-per      ;; Set to the day in which the student is during the presymptomatic period
  latent-per        ;; Set to the day in which the student is during the latent period
  sympt-per         ;; Set to the day in which the student is during the symptomatic period
  mask?             ;; True if the student is using a mask, false otherwise
]

instructors-own [
  main?             ;; True if it is the main instructor
  question?         ;; True if it is attending a question
  walking-around?   ;; True if just walking around
  target-patch      ;; Target-patch / seat for question
  target-chair      ;; Target chair number for question
  moving-time       ;; How long it is going to move for while walking around
  clear1?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  clear2?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  clear3?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  clear4?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  clear5?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  clear6?           ;; Used in moving procedures as one step of the movement, true if it has already been done
  steps             ;; Contains the amount of steps remaining to take for a certain part of movement
  pathway-x         ;; Contains which column pathway it is going to take for the question i.e 0 for 1st column of labs 1 for 2nd column of labs
  target            ;; Used as a target to where the instructor / ta wants to go next
  answering         ;; Amount of time its gonna spend answering the question
  go-back?          ;; True if it is going back meaning there are no questions to answer and not waliking around
  avoiding?         ;; True if it is avoiding the grey lab (meaning not moving through it but around it)
  first?            ;; Used for loop purposes (if statements that should only be run through once)
  saved-spot        ;; Contains patch saved for itself at the demonstration it will do
  dem-lab-number-i  ;; Current demonstration lab number to go to, 99 if no lab / demonstration at the moment
  prev-lab-number-i ;; Previous demonstration lab number
  contact-tracing   ;; List containting the amount of seconds instructor is in contact with all other persons. List is the size of the amount of turtles
  contacts          ;; List of the who of the turtles the instructor has been in contact with, in order from most length contact to least lengthy contact
  contacts-shorted  ;; Same as contacts list but removes the contacts that lasted less than 5 seconds
  ticks-in-contact  ;; Like the contact-tracing list but in ticks rather than seconds
  ticks-in-contact-order  ;; Same as contact-tracing list but the elements are in order from greatest amount of seconds to least amount of seconds
  avg-ticks         ;; Average ticks instructor is in contact with other persons
  infected?         ;; True if the instructor is infected, false otherwise
  presympt          ;; True if the instructor will be presymptomatic (not showing symptoms), false otherwise
  sympt             ;; True if the instructor will be symptomatic (showing symptoms), false otherwise
  presympt-per      ;; Set to the day in which the instructor is during the presymptomatic period
  latent-per        ;; Set to the day in which the instructor is during the latent period
  sympt-per         ;; Set to the day in which the instructor is during the symptomatic period
  mask?             ;; True if the instructor is using a mask, false otherwise
]

patches-own [
  chair?            ;; True if patch is a chair
  c-paired?         ;; True if the student is paired with a student
  chair-number      ;; Cointains the chair number
  occupied?         ;; True if the spot around the demonstration has already been occupied
  used?             ;; Similar to occupied?, both just have to be used for proper organization of students around the demonstration
  dem-lab-number-p  ;; Used to determine what demonstration the patch is a part of, useful for setting students around the correct demonstration
  saved-seat?       ;; True if the chair has already been "saved" for someone in the group
  imag-number       ;; Numbering of labs from left to right and in "snake" form starting from the bottom one, used to for section divided among columns
]

;;;;;;;;;;;;;;;;;;;;;
;;;SETUP PROCEDURE;;;---------------------------------------------------------------------------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  ;read-parameters
  setup-world
  setup-labs
  setup-chairs
  setup-students
  setup-instructors
  setup-masked ;sets up masked people
  ask n-of round (presymptomatic / 100 * initial-outbreak-size) turtles [be-presymptomatic]  ;; Sets how many people are initially presymptomatic
  ask n-of round (initial-outbreak-size - (presymptomatic / 100 * initial-outbreak-size)) turtles [be-symptomatic]  ;; Sets how many people are initially presymptomatic
  ask instructors with [infected? = true] [set color pink - 1]
  reset-ticks
end

;; Function reads all the parameters from input text file
to read-parameters
  file-open "Lab-room-parameters.txt"
  let waste file-read-line
  set waste file-read-line
  set waste file-read-line
  set room-width file-read
  set waste file-read-line
  set room-height file-read
  set waste file-read-line
  set room-margin-x file-read
  set waste file-read-line
  set room-margin-y file-read
  set waste file-read-line
  set number-of-rows file-read
  set waste file-read-line
  set number-of-columns file-read
  set waste file-read-line
  set table-width file-read
  set waste file-read-line
  set table-height file-read
  set waste file-read-line
  set chairs-per-table file-read
  set waste file-read-line
  set number-of-students file-read
  set waste file-read-line
  set percentage-of-groups file-read
  set waste file-read-line
  set avg-group-size file-read
  set waste file-read-line
  set num-of-instructors/TAs file-read
  set waste file-read-line
  set social-radius file-read
  set waste file-read-line
  set avg-freq-question file-read
  set waste file-read-line
  set avg-answering-time file-read
  set waste file-read-line
  set lab-time file-read
  set waste file-read-line
  set introduction-time file-read
  set waste file-read-line
  set demonstration-time file-read
  set waste file-read-line
  set number-of-demonstrations file-read
  set waste file-read-line
  set demonstration-lab-tables file-read
  set waste file-read-line
  set fraction-students-per-dem file-read
  set waste file-read-line
  set number-of-sections file-read
  set waste file-read-line
  set sections-split-across file-read
  set waste file-read-line
  set initial-outbreak-size file-read
  set waste file-read-line
  set presymptomatic file-read
  set waste file-read-line
  set mask-efficiency file-read
  set waste file-read-line
  set percentage-of-masked-people file-read
  file-close
end

to setup-world
  resize-world 0 room-width 0 room-height
  set-patch-size 15

  ;; Setting up variables
  ask patches [
    set chair? false
    set c-paired? false
    set occupied? false
    set used? false
    set saved-seat? false
    set chair-number 999
    set imag-number 999
    set dem-lab-number-p 999
  ]

  ;; The grey lab table in the front of the room
  ask patches with [pxcor > (room-width / 2 - 5) and pxcor < (room-width / 2 + 5) and pycor > (room-height - room-margin-y - 4) and pycor < (room-height - room-margin-y + 1)][
    set pcolor white
  ]
  ask patch (room-width / 2) (room-height - room-margin-y - 2) [
    set plabel 0
    set plabel-color black
  ]

  set demonstration? true
  if number-of-demonstrations = 0 [
    set demonstration? false
  ]

  if demonstration? = false [set demonstration-time 0]
  if number-of-sections > 1 [
    set time-per-section int (((lab-time - introduction-time - (demonstration-time * number-of-demonstrations)) / number-of-sections ) * 400)
  ]

  set demonstrations number-of-demonstrations
  if fraction-students-per-dem >= number-of-demonstrations [
    set demonstrations fraction-students-per-dem
  ]

  set first-time? true
  let plus 0
  set dem-labs []
  set m 1
  ;; Reading the demonstration lab numbers and putting them in list dem-labs
  if demonstration? [
    set z 0
    while [z - plus < number-of-demonstrations] [
      let lab item z demonstration-lab-tables
      if lab = "." [
        set z z + 1
        set lab item z demonstration-lab-tables
        set z z + 1
        set lab word lab (item z demonstration-lab-tables)
        set plus 2
      ]
      set lab read-from-string lab
      set dem-labs lput lab dem-labs
      set z z + 1
    ]
    set z 1
  ]
end

;; Function sets all the lab tables in the room
to setup-labs
  set tables-per-section []
  ;; Setting the number of tables each experiment section will have. They're set in list tables-per-section
  if number-of-sections > 1 [
    let tables int (number-of-rows * number-of-columns / number-of-sections)
    let remaining remainder (number-of-rows * number-of-columns) number-of-sections
    let i 0
    let add 1
    while [i < number-of-sections] [
      if remaining <= 0 [
        set add 0
      ]
      set tables-per-section lput (tables + add) tables-per-section
      set remaining remaining - 1
      set i i + 1
    ]
  ]

  set column-space int ((room-width - (room-margin-x) - 2 * (number-of-columns - 1) - (number-of-columns * table-width) - 1) / (number-of-columns))
  set row-space  int ((room-height - (2 * room-margin-y) - (10) - (number-of-rows * table-height)) / (number-of-rows - 1))
  ;; Space between the Columns  and rows of the lab tables needs to be big enough
  if column-space < 4 or row-space < 3 [  ;; Values higher than this will have overlaping elements or not enough room to walk
    ifelse column-space < 4 and row-space < 3 [
     user-message "Invalid table-width and table-height for such number of rows or columns"
    ]
    [ ifelse column-space < 4 [
        user-message "Invalid table-width for such number of columns. Decrease table-width, margin or number-of-columns or increase room-width"
      ]
      [
        user-message "Invalid table-height for such number of rows. Decrease table-height, margin or number-of-rows or increase room-height"
      ]
    ]
  ]

  let s 0
  let sec 0
  let colors 25
  if number-of-sections > 1 [
    set s item 0 tables-per-section
  ]
  let c 0
  let x room-margin-x
  ;; Ahead, actually setting the lab tables in the room
  while [c < number-of-columns][
    let r 0
    let y room-margin-y + 2
    ;; Part that connects lab tables in the same column (bar to the left)
    ask patches with [pxcor > (x - 1) and pxcor < (x + 2) and pycor > (y - 3) and pycor < (y + (table-height * number-of-rows) + (row-space * (number-of-rows - 1)) + 2)][
      set pcolor white
    ]
    while [r < number-of-rows][
      ;; Each table is created
      ask patches with [pxcor > (x + 1) and pxcor < (x + table-width + 2) and pycor > (y - 1) and pycor < (y + table-height)][
        set pcolor white
      ]
      ask patch (x + 1 + (table-width / 2)) (y + (table-height / 2) - 1) [
        ;; Setting the center patch of a lab table to the color corresponding to its section when sections are being split into columns
        if sections-split-across = "columns" and number-of-sections > 1 [
          ifelse s != 0 [
            set pcolor colors
            set s s - 1
          ]
          [
            set colors colors + 20
            set pcolor colors
            set sec sec + 1
            set s (item sec tables-per-section) - 1
          ]
        ]
        set plabel r + (c * number-of-rows) + 1
        set plabel-color black
      ]
      set r r + 1
      set y y + table-height + row-space
    ]
    set c c + 1
    set x x + table-width + column-space + 2
  ]

  ;; Set the xcor of the pathways for each hallway column
  set pathways-xcor []
  let n 1
  while [n <= number-of-columns] [
    set pathways-xcor lput (room-margin-x + (4 * n) + (n * table-width) + ((column-space - 2) * (n - 1))) pathways-xcor
    set n n + 1
  ]
  set extra column-space - 3

  set n 0
  ;; Lab tables were demonstrations will happen get a certain tone of grey for color
  while [n < number-of-demonstrations] [
    ask one-of patches with [plabel = (item n dem-labs) and pcolor != red][
      ifelse (item n dem-labs) = 0 [ ;; If not top table
        ask patches with [pxcor > (room-width / 2 - 5) and pxcor < (room-width / 2 + 5) and pycor > (room-height - room-margin-y - 4) and pycor < (room-height - room-margin-y + 1)][
          set pcolor (6 - n)
        ]
      ]
      [
        ask other patches with [pcolor != black and pxcor > ([pxcor] of myself - table-width / 2) and pxcor <= ([pxcor] of myself + table-width / 2) and pycor >= ([pycor] of myself - table-height / 2) and pycor <= ([pycor] of myself + table-height / 2)]
        [set pcolor (6 - n)]
      ]
    ]
    set n n + 1
  ]


  ;; Setting the center patch of a lab table to the color corresponding to its section when sections are being split into rows
  if sections-split-across = "rows"  and number-of-sections > 1 [
    let i 0
    let j 0
    set x [pxcor] of min-one-of patches with [plabel-color = black and pcolor != red][distance patch 0 0]
    let y [pycor] of min-one-of patches with [plabel-color = black and pcolor != red][distance patch 0 0]
    while [i < number-of-rows * number-of-columns] [
      set j j + 1
      ask min-one-of patches with [plabel-color = black and pcolor != red and pycor = y and imag-number = 999][distance patch x y] [
        set imag-number i + 1
        if j = number-of-columns [
          if number-of-rows != number-of-sections [set x pxcor]
          set y pycor + table-height + row-space
          set j 0
        ]
        ifelse s != 0 [
          set pcolor colors
          set s s - 1
        ]
        [
          set colors colors + 20
          set pcolor colors
          set sec sec + 1
          set s (item sec tables-per-section) - 1
        ]
      ]
      set i i + 1
    ]
  ]

end

to setup-chairs
  ;; Extra chair would be the one that is set in the edge of the lab table
  let extra-chair? false
  set chairs-per-side (chairs-per-table / 2)
  if (remainder chairs-per-table 2 != 0) [
    set extra-chair? true
    set chairs-per-side ((chairs-per-table - 1) / 2)
  ]
  ;; Space between chairs on the same side of the table
  let chair-space 0
  if chairs-per-side > 1 [
    set chair-space ((table-width - 2 - (1 * chairs-per-side)) / (chairs-per-side - 1))
    if chair-space < 1 [
      user-message "Invalid chairs-per-table for such number of table-width"
    ]
  ]
  let c 0
  let x (room-margin-x + 2)
  let i 1
  while [c < number-of-columns][
    let r 0
    let y room-margin-y
    while [r < number-of-rows][
      let s 0
      while [s < chairs-per-side][
        ;; Chairs on the lower side of the table
        ask patches with [pxcor = (x + 1 + (s * chair-space) + (s * 1)) and pycor = (y + 1)][
            set pcolor red
            set chair? true
            set c-paired? false
            set chair-number i
            set plabel chair-number
        ]
        set i i + 1
        set s s + 1
      ]
      set y y + table-height + 1
      set s 0
      while [s < chairs-per-side][
        ;; Chairs on the upper side of the table
        ask patches with [pxcor = (x + table-width - (s * chair-space) - (s * 1) - 2) and pycor = (y + 1)][
            set pcolor red
            set chair? true
            set c-paired? false
            set chair-number i
            set plabel chair-number
        ]
        set i i + 1
        set s s + 1
      ]
      if extra-chair? [
        ;; Extra chair on the edge of the tables
        ask patches with [pxcor = (x + table-width) and pycor = (y - table-height + 1 + int (table-height / 2))][
          set pcolor red
          set chair? true
          set c-paired? false
          set chair-number i
          set plabel chair-number
        ]
        set i i + 1
      ]
      set r r + 1
      set y y + row-space - 1
    ]
    set c c + 1
    set x x + table-width + column-space + 2
  ]
  set num-chairs count patches with [chair?]
end

to setup-students
  create-students number-of-students [
    if number-of-students > num-chairs [ user-message "Invalid number-of-students for such number of chairs. Click halt" stop]
    set size 1.5
    set color [255 0 0 0]
    set s-paired? false
    set clear1? false
    set clear2? false
    set clear3? false
    set clear4? false
    set clear5? false
    set question? false
    set attended? false
    set avoiding? false
    set extra-movement? false
    set friends? false
    set change-seat? false
    set follower? true
    set first? true
    set positions-list [-1 1 3 -2 2]
    set location 0
    set num-in-group 0
    set follow-position 0
    set contact-tracing []
    set contacts []
    set ticks-in-contact []
    let i 0
    while [i < number-of-students + num-of-instructors/TAs][
      set ticks-in-contact lput 0 ticks-in-contact
      set i i + 1
    ]
    set avoidances 0
    set target NOBODY
    set steps 0
    set next-question 0
    set ycor 0
    set heading 0
    set shape "person"
    ;set size 2.0
    set infected? false
    set mask? false
  ]
  ;; Students that will be part of a group
  let students-per-table int (number-of-students / (number-of-rows * number-of-columns))
  let plus-one-student remainder number-of-students (number-of-rows * number-of-columns)
  ask n-of int ((percentage-of-groups / 100) * number-of-students) students [
    set friends? true
    set num-in-group random avg-group-size + 2
    if num-in-group > students-per-table + ceiling (plus-one-student / 50) [
      set num-in-group students-per-table + ceiling (plus-one-student / 50)
    ]
  ]
  let n avg-group-size + 2
  ;; This while statement sets up the students with their groups
  while [n >= 2] [
    let amount count students with [num-in-group = n]
    ;; Next part makes sure that the number of students assigned to a group matches the sizes of each group i.e no one is left over
    ask n-of (remainder amount n) students with [num-in-group = n][
      set num-in-group num-in-group - 1
      if num-in-group = 1 [
        set friends? false
        set num-in-group 0
      ]
    ]

    if (n = students-per-table + ceiling (plus-one-student / 50)) and count students with [num-in-group = n] > (plus-one-student * (students-per-table + ceiling (plus-one-student / 50)))[
      ask n-of ((count students with [num-in-group = n]) - (plus-one-student * (students-per-table + ceiling (plus-one-student / 50)))) students with [num-in-group = n][
        set num-in-group num-in-group - 1
        if num-in-group = 1 [
          set friends? false
          set num-in-group 0
        ]
      ]
    ]

    set amount count students with [num-in-group = n]
    ;; Next part sets up the main student who is going to be "followed" in each group
    ask n-of (amount / n) students with [num-in-group = n][
      set follower? false
      set waiting 2100 - 100 * (exp (random-float 3))
      set xcor one-of list 1 (room-width - 1)
      set chair-num [chair-number] of one-of patches with [chair? and c-paired? = false and saved-seat? = false]
      ;; While loop makes sure that the lab table of the chair that has been assigned to the student has enough seats for his friends
      while [ s-paired? = false ] [
        let full-table students-per-table
        if plus-one-student > 0 [
          set full-table full-table + 1
        ]
        let seat one-of patches with [chair? and chair-number = [chair-num] of myself]
        ifelse ((count patches with [int ((chair-number - 1) / chairs-per-table) =  int (([chair-number] of seat - 1)/ chairs-per-table) and c-paired? = false and saved-seat? = false and chair?]) < (n + chairs-per-table - full-table) ) [
          set chair-num [chair-number] of one-of patches with [chair? and c-paired? = false and saved-seat? = false]
        ]
        [ set s-paired? true
          ask seat [set c-paired? true set saved-seat? true]
          ask n-of (n - 1) patches with [chair? and c-paired? = false and saved-seat? = false and int ((chair-number - 1) / chairs-per-table) =  int (([chair-number] of seat - 1) / chairs-per-table)][ set saved-seat? true ]
          if count patches with [int ((chair-number - 1) / chairs-per-table) =  int (([chair-number] of seat - 1)/ chairs-per-table) and chair? and saved-seat?] >= full-table [
            ask patches with [int ((chair-number - 1) / chairs-per-table) =  int (([chair-number] of seat - 1)/ chairs-per-table) and chair?] [ set saved-seat? true ]
            if full-table > students-per-table [ set plus-one-student plus-one-student - 1]
          ]
        ]
      ]
    ]
    ;; Next part sets up the variables for the students that are "following" someone within their group
    ask students with [num-in-group = n and follower?][
      set following one-of students with [num-in-group = n and follower? = false and count my-blue-links < (n - 1)]
      create-blue-link-with following [set color blue]
      set waiting [waiting] of following
      set xcor [xcor] of following
      set chair-num [chair-number] of one-of patches with [chair? and c-paired? = false and saved-seat? and int ((chair-number - 1) / chairs-per-table) =  int (([chair-num] of ([following] of myself) - 1) / chairs-per-table)]
      set s-paired? true
      ask one-of patches with [chair-number = [chair-num] of myself][set c-paired? true]
    ]
    set n n - 1
  ]
  ;; Now the students without a friend group get their chair values along with other variables
  ask students with [friends? = false][
    let full-table students-per-table
    if plus-one-student > 0 [
      set full-table full-table + 1
    ]
    let i 0
    while [i < number-of-rows * number-of-columns][
      if count patches with [(int ((chair-number - 1) / chairs-per-table) = i) and chair? and saved-seat?] >= full-table [
        ask patches with [(int ((chair-number - 1) / chairs-per-table) = i) and chair?][ set saved-seat? true ]
      ]
      set i i + 1
    ]
    set waiting 2100 - 100 * (exp (random-float 3))
    set xcor one-of list 1 (room-width - 1)
    set chair-num [chair-number] of one-of patches with [chair? and c-paired? = false and saved-seat? = false]
    set s-paired? true
    ask one-of patches with [chair-number = [chair-num] of myself][set c-paired? true set saved-seat? true]
    if count patches with [int ((chair-number - 1) / chairs-per-table) =  int (([chair-num] of myself - 1)/ chairs-per-table) and chair? and saved-seat?] >= full-table [
      ask patches with [int ((chair-number - 1) / chairs-per-table) =  int (([chair-num] of myself - 1)/ chairs-per-table) and chair?] [ set saved-seat? true ]
      if full-table > students-per-table [ set plus-one-student plus-one-student - 1 ]
    ]
  ]

  set tables-per-groups []
  ;; Setting the number of tables for each group of students divide up for the demonstrations. They're set in list tables-per-group
  if fraction-students-per-dem > 1 [
    let tables int (number-of-rows * number-of-columns / fraction-students-per-dem)
    let remaining remainder (number-of-rows * number-of-columns) fraction-students-per-dem
    let i 0
    let add 1
    while [i < fraction-students-per-dem] [
      if remaining <= 0 [
        set add 0
      ]
      set tables-per-groups lput (tables + add) tables-per-groups
      set remaining remaining - 1
      set i i + 1
    ]
  ]

  ;; All students are assigned a few final variables now that they have proper seats assigned
  ask students [
    ;; Setting the offset-number for each group of students, that being the demonstration lab they will be at relative to the first group
    ifelse fraction-students-per-dem > 1 [
      set offset-number 99
      let i 0
      let total-seats 0
      while [i < fraction-students-per-dem and offset-number = 99] [
        set total-seats total-seats + ((item i tables-per-groups) * chairs-per-table)
        if chair-num <= total-seats [
          set offset-number i
        ]
        set i i + 1
      ]
    ]
    [ set offset-number 0 ]
    ;; Setting dem-lab-number-s, 99 for those who will be seated for the following demonstration
    ifelse offset-number >= number-of-demonstrations [
     set dem-lab-number-s 99
    ]
    [ set dem-lab-number-s item offset-number dem-labs ]
    set pathway-x int ((chair-num - 1) / (chairs-per-table * number-of-rows))
    set target-patch one-of patches with [chair-number = [chair-num] of myself]
    let remaining ((remainder (chair-num - 1) (chairs-per-table * number-of-rows)) + 1)
    let remaining2 remainder remaining chairs-per-table
    (ifelse remainder remaining chairs-per-table = 0 [
      set location 2  ;; For the students at the edges of the table
      ]
      int ((remaining2 - 1) / (chairs-per-side)) = 0 [
        set location 1    ;; Students at the lower side of the seats
      ]
      int ((remaining2 - 1) / (chairs-per-side)) = 1 [
        set location 3   ;; Students at the upper side of the seats
      ]
    )
  ]

end

to setup-instructors
  create-instructors num-of-instructors/TAs [
    set size 1.5
    set color 58
    set heading 180
    set main? true
    set question? false
    set walking-around? false
    set clear1? true
    set clear2? true
    set clear3? true
    set clear4? true
    set clear5? true
    set clear6? true
    set first? true
    set go-back? false
    set avoiding? false
    set prev-lab-number-i 0
    set answering 0
    set target NOBODY
    set steps 0
    set contact-tracing []
    set contacts []
    set ticks-in-contact []
    let i 0
    while [i < number-of-students + num-of-instructors/TAs][
      set ticks-in-contact lput 0 ticks-in-contact
      set i i + 1
    ]
    set shape "instructor"
    ;set size 2.0
    set infected? false
    set mask? false
    setxy (room-width / 2) (room-height - room-margin-y + 1)
  ]
  ;; Some variables and locations are setup for instructors that are not considered the "main" one
  ask n-of (num-of-instructors/TAs - 1) instructors [    ;; Leaves only one main instructor, rest are moved to random parts of the upper part of the room
    set color green
    set main? false
    let i one-of [0 1]
    while [count other turtles in-radius social-radius != 0][
      move-to one-of patches with [pycor >= (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) and pcolor = black]
    ]
  ]
  ;; Some variables setup for the instructor that is considered the "main" one
  ask instructors [
    if length dem-labs > 0 [
      set dem-lab-number-i item 0 dem-labs
    ]
  ]
end

;;;;;;;;;;;;;;;;;;
;;;GO PROCEDURE;;;--------------------------------------------------------------------------------------------------------------------------------------------------------------
;;;;;;;;;;;;;;;;;;

to go
  setup-time

  move-students
  move-instructors

  chance-of-infection

  ;; Setting all the variables for behavior space testing like calculating the average number of contacts and average contact seconds at the end of the lab period
  if ticks > (2000 + lab-time * 400 + 3200)[
    let sum1 0
    let sum2 0
    ask turtles [
      let i 0
      let sum-ticks 0
      while [i < length ticks-in-contact][
        set contact-tracing lput (int (item i ticks-in-contact / (400 / 60))) contact-tracing
        set sum-ticks sum-ticks + (item i contact-tracing)
        set i i + 1
      ]
      set i 0
      set ticks-in-contact-order []
      set contacts-shorted []
      while [i < length contacts][
        set ticks-in-contact-order lput (item (item i contacts) contact-tracing) ticks-in-contact-order
        if item (item i contacts) contact-tracing > 5 [
          set contacts-shorted lput (item i contacts) contacts-shorted
        ]
        set i i + 1
      ]
      repeat (length contact-tracing - length contacts) [
        set ticks-in-contact-order lput 0 ticks-in-contact-order
      ]
      set sum1 sum1 + length contacts-shorted
      set avg-ticks (sum-ticks / count turtles)
      set sum2 sum2 + avg-ticks
    ]
    set avg-contact sum1 / count turtles
    set avg-contact-seconds sum2 / count turtles
    stop
  ]

  tick
end

;;;MOVEMENT OF STUDENTS AND ITS FUNCTIONS;;;-------------------------------------------------------------------------------------------------------------------------------------

;; Responsible for the movement of all students depending on the time and the movement its already completed, calls other functions
to move-students
  ask students [
    ;; Moves students to seat
    (ifelse ticks < (2000 + introduction-time * 400) [
      if waiting <= 0 [
        if color = [255 0 0 0] [set color blue if infected? [set color pink]]
        check-clear     ;; Checks if student is clear of other students in front at a distance less than the social radius
        if clear? [
          check-for-contact
          ifelse follower? = false or friends? = false [move-to-seat]   ;; Unless the student has friends and is a follower it'll move-to-seat as function instructs
          [follow-guide]
        ]
      ]
    ]
    ;; Setting up variables before the demonstration
    demonstration? and ticks = (2000 + (introduction-time + (demonstration-time * (z - 1))) * 400 + 1) [
      if z = 1 or prev-lab-number-s = 99 [ ;; If coming from being seated
        set clear1? false
        set clear2? false
        set clear3? false
        set clear4? false
        set clear5? false
        move-to target-patch
        if int ((chair-num - 1)/ chairs-per-table) + 1 != dem-lab-number-s [
          face one-of neighbors4 with [pcolor = white or (pcolor <= 6 and pcolor >= 1)]
          rt 180
        ]
      ]
      if dem-lab-number-s = 99 [
        ask one-of patches with [pcolor = red and plabel = [chair-num] of myself][
          set used? true
          ask neighbors with [pcolor = black and used? = false and pycor = [pycor] of myself][set used? true]
        ]
      ]
      if target != NOBODY [face target]
      set first-time? true
      check-for-contact
    ]
    ;; Moving to the demonstration
    demonstration? and ticks < (2000 + (introduction-time + (demonstration-time * z)) * 400) [
      ifelse dem-lab-number-s != 99 [
        ifelse z = 1 or prev-lab-number-s = 99 [
          if clear3? = false or clear4? [check-for-contact]
          move-to-demonstration
        ] ;; If coming from being seated
        [ check-for-contact
          move-to-another-demonstration ]
      ]
      ;; If dem-lab-number-s = 99 it means it should be seated so it goes to its seat
      [
        check-for-contact
        if z != 1 [
          ifelse extra-movement? [extra-movement] ;; If it has to do an "extra-movement" before going to seat
          [ move-to-seat ]
        ]
      ]
    ]
    ;; Setting up variables after the demonstration
    demonstration? and ticks = (2000 + (introduction-time + (demonstration-time * z)) * 400) [
      set clear2? false
      set clear3? false
      set clear4? false
      ;; Setting up all variables for next demonstration
      ifelse z != demonstrations [ ;; If the number of demonstrations that have happened is still not equal to all the demonstrations that should happen
        set clear1? false
        set avoidances 0
        set prev-lab-number-s dem-lab-number-s
        let item-num z + offset-number
        ifelse fraction-students-per-dem > number-of-demonstrations [
          if item-num >= fraction-students-per-dem [ ;; If not in range of list, needs to the "first" lab demonstration in the list
            set item-num remainder item-num fraction-students-per-dem
          ]
        ]
        [
          if item-num >= number-of-demonstrations [ ;; If not in range of list, needs to the "first" lab demonstration in the list
            set item-num remainder item-num number-of-demonstrations
          ]
        ]
        ifelse item-num >= number-of-demonstrations [
         set dem-lab-number-s 99
        ]
        [ set dem-lab-number-s item item-num dem-labs ]
        if first-time? and z < number-of-demonstrations [
          if fraction-students-per-dem <= 1 [
            ;; Instructors change lab number when there is only one group of students moving from lab to lab, otherwise they all stay at their respective demonstrations
            ask instructors [
              set prev-lab-number-i dem-lab-number-i
              set dem-lab-number-i item z dem-labs
              set first? true
            ]
          ]
          set first-time? false
        ]
        ;; Reseting the patches where students gather around the demonstrations
        ask patches with [used?] [set used? false]
        ask patches with [occupied?] [set occupied? false]
        if dem-lab-number-s != 99 [ ;; Setting target for next demonstration
          ;; For when they're not above all labs
          ifelse ycor < (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))[ ;; That ycor in parenthesis will show up a lot and is simply the point two patches above all the lab tables (white patches)
            let section number-of-columns - 1
            let i 0
            while [section = number-of-columns - 1 and i < number-of-columns ][ ;; Getting what part of the student is currently at (what lab column)
              if xcor <= ((item i pathways-xcor) + extra + 1) [
                set section i
              ]
              set i i + 1
            ]
            ;; If already in hallway (not on top or bottom of lab table
            ifelse xcor >= (item section pathways-xcor - 1) and xcor <= (item section pathways-xcor + extra) [
              ;; If already in hallway where it wants to go, skip clear1
              ifelse section = int ((dem-lab-number-s - 1) / number-of-rows) and dem-lab-number-s != 0 [
                set clear1? true
                set target patch-here
              ]
              [
                ;; Setting target to either bottom or top of all lab tables depending on whether or not its on the top half of the previous demonstration
                ifelse ycor > [pycor] of one-of patches with [plabel = [prev-lab-number-s] of myself and pcolor != red] or dem-lab-number-s = 0 [
                  set target patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
                ]
                [ set target patch xcor (room-margin-y - 2) ]
              ]
            ]
            [
              ;; Setting target to nearby hallway
              set target min-one-of patches with [pxcor >= (item section pathways-xcor - 1) and pxcor <= (item section pathways-xcor + extra)][distance myself]
            ]
          ]
          ;; If on top of all lab tables
          [
            ;; If next demonstration is on top lab table skip clear 1 & 2
            ifelse dem-lab-number-s = 0 [
              set target patch-here
              set clear1? true
              set clear2? true
            ]
            [
              ;; Setting target to a patch in the correct hallway of the next demonstration where it needs to go. Skips clear1
              set clear1? true
              let path int ((dem-lab-number-s - 1) / number-of-rows)
              set target patch (item path pathways-xcor + random extra) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            ]
          ]
          face target
        ]
      ]
      [ set dem-lab-number-s 99 ]
      ;; Setting variables for when it needs to go back to its seat for either the end of all demonstrations or waiting to go to another demonstration
      if dem-lab-number-s = 99 [
        set clear1? true
        set follow-position 0
        ;; Step clear1? in the move-to-seat function will be skipped
        ifelse ycor < (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))[ ;; For when its not above all lab tables                                                                                                      ;; Given an extra-movement to do if standing in a hallway during demonstration
          set extra-movement? true
          let section number-of-columns - 1
          let i 0
          while [section = number-of-columns - 1 and i < number-of-columns ][ ;; Getting what part of the student is currently at (what lab column)
            if xcor <= ((item i pathways-xcor) + extra + 1) [
              set section i
            ]
            set i i + 1
          ]
          ;; Setting target to the closest hallway patch
          set target min-one-of patches with [ pxcor >= (item section pathways-xcor - 1) and pxcor <= (item section pathways-xcor + extra) ][distance myself]
        ]
        [ ;; Setting target for patch in correct hallway of seat
          set target patch (item pathway-x pathways-xcor + random extra) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) ]
        face target
        ;; If already at its seat it skips all moving steps
        if patch-here = target-patch [
          set extra-movement? false
          set clear2? true
          set clear3? true
          set clear4? true
          set target patch-here
          (ifelse location = 3 [ set heading 180 ]
          location = 2 [ set heading 270 ]
          location = 1 [ set heading 0 ])
        ]
      ]
    ]
    ;; Moving back to seat after demonstration
    demonstration? and ticks < (2000 + (introduction-time + (demonstration-time * demonstrations) + 1) * 400) [
      ifelse z != demonstrations [ ;; If not all demonstrations have been done
        set z z + 1
      ]
      ;; Else it returns to seat
      [
        ;; Lab tables back to original white color
        ask patches with [pcolor <= 6 and pcolor >= 1][set pcolor white]
        check-for-contact
        ifelse extra-movement? [extra-movement] ;; If it has to do an "extra-movement" before going to seat
        [ move-to-seat ]
      ]
    ]
    ;; Facing the table once the demonstration is over
    ticks <= (2000 + (introduction-time + (demonstration-time * demonstrations) + 1) * 400) [
      check-for-contact
      move-to target-patch
      face one-of neighbors4 with [pcolor = white]
    ]

    ;; Makes student ask questions during lab-time and move to a different section of the room if neccessary
    ticks < (2000 + lab-time * 400) [
      check-for-contact
        if random (avg-freq-question * (count students with [int ((chair-num - 1) / chairs-per-table) = int (([chair-num] of myself - 1) / chairs-per-table)]) * 400) = 1 and next-question <= 0 and chair-num = chair-number and count students with [ ( int ((chair-num - 1) / chairs-per-table) = int (([chair-num] of myself - 1) / chairs-per-table)) and question? ] = 0 [
        set question? true
        set color yellow
      ]
      ;; If it is time to move from one experiment section to another it sets up all the variables
      if number-of-sections > 1 and remainder (ticks - 2000 - ((introduction-time + (demonstration-time * number-of-demonstrations)) * 400) ) time-per-section = 0 and ticks < (1600 + lab-time * 400)[
        set change-seat? true
        set clear1? false
        set clear2? false
        set clear3? false
        set clear4? false
        let current-table int ((chair-num - 1) / chairs-per-table) + 1
        let tables-in-section item 0 tables-per-section
        ifelse sections-split-across = "columns" [
          ;; Chair number jumps the appropriate amount of tables to move to next table
          set chair-num chair-num + (chairs-per-table * tables-in-section)
          ;; If chair number greater than the number of chairs it takes the remainder of the number of chairs
          if chair-num > (number-of-rows * number-of-columns * chairs-per-table) [
            set chair-num remainder chair-num (number-of-rows * number-of-columns * chairs-per-table)
          ]
        ]
        [
          ;; For sections split into rows it does the same thing but considering the imaginary numbering in snake form, starting in bottom left and going from left to right
          let next-table ([imag-number] of one-of patches with [plabel = current-table and pcolor != red]) + tables-in-section
          if next-table > (number-of-rows * number-of-columns) [
            set next-table remainder next-table (number-of-rows * number-of-columns)
          ]
          ;; After getting its next table it then looks for the seat in the same position as before in that next table
          set next-table [plabel] of one-of patches with [imag-number = next-table and pcolor != red]
          let place (remainder (chair-num - 1) chairs-per-table) + 1
          set chair-num ((next-table - 1) * 5) + place
        ]
        ;; Changing other variables corresponding to its new seat
        set pathway-x int ((chair-num - 1) / (chairs-per-table * number-of-rows))
        set target-patch one-of patches with [chair-number = [chair-num] of myself]
        let remaining ((remainder (chair-num - 1) (chairs-per-table * number-of-rows)) + 1)
        let remaining2 remainder remaining chairs-per-table
        (ifelse remainder remaining chairs-per-table = 0 [
            set location 2  ;; For the students at the edges of the table
          ]
          int ((remaining2 - 1) / (chairs-per-side)) = 0 [
            set location 1    ;; Students at the lower side of the seats
          ]
          int ((remaining2 - 1) / (chairs-per-side)) = 1 [
            set location 3   ;; Students at the upper side of the seats
          ]
        )
        let section number-of-columns - 1
        let i 0
        while [section = number-of-columns - 1 and i < number-of-columns ][ ;; Getting what part of the student is currently at (what lab column)
          if xcor <= ((item i pathways-xcor) + extra + 1) [
            set section i
          ]
          set i i + 1
        ]
        rt 180
        fd 1
        ;; Setting target to a patch in the closest hallway
        set target patch (item section pathways-xcor - 1 + random (extra + 1)) ycor
        face target
      ]
      if change-seat? [check-clear if clear? [change-seat] ]
    ]

    ;; Sets up the students to leave the room
    ticks = (2000 + lab-time * 400) [
      check-for-contact
      set follow-position 0
      set positions-list [-1 1 3 -2 2]
      set clear1? false
      set clear2? false
      set clear3? false
      set clear4? false
      ;; Gives students a waiting time, students in the same table get similar waiting to leave values (as they usually go out at similar times)
      let already-waiting other students with [( int ((chair-num - 1) / chairs-per-table) = int (([chair-num] of myself - 1)  / chairs-per-table) ) and (waiting > 0)]
      if waiting < 0 [
        ifelse not any? already-waiting [
          set waiting random 1600 + 2 ]
        [set waiting ([waiting] of min-one-of already-waiting [waiting] + random 200)]
      ]
    ]
    ;; Setting up the students with groups for leaving. The person that is going to be followed is switched to one on the highest location if not already the one. This is done for easier movement in groups
    ;; Waiting times are also updated to the waiting time of the person being followed
    ticks = (2000 + lab-time * 400 + 1) [
      check-for-contact
      if friends? and follower? = false and following = 0 [
        let higher blue-link-neighbors with [location > [location] of myself]
        ;; Changing the person that is being followed if necessary
        ifelse count higher != 0 [
          let three higher with [location = 3]
          ifelse count three != 0 [
            ask one-of three [set follower? false]
          ]
          [ ask one-of higher with [location = 2] [set follower? false] ]
          set follower? true
          set following one-of blue-link-neighbors with [follower? = false]
          set waiting [waiting] of following
          ask blue-link-neighbors with [follower?][
            ask my-blue-links [die]
            set following [following] of myself
            set waiting [waiting] of following
            create-blue-link-with following [set color blue]
          ]
        ]
        [
          ask blue-link-neighbors [
            set waiting [waiting] of myself
          ]
        ]
      ]
    ]

    ;; Moves students out of room once their waiting time is done
    waiting <= 0 [
      check-for-contact
      (ifelse any? students with [( int ((chair-num - 1) / chairs-per-table) = int (([chair-num] of myself - 1)  / chairs-per-table) ) and (question?)][
        ;; Extends the waiting time if someone is still being asked a question
        set waiting random 200 + 200
        if friends? [
          ifelse follower? [
            ask one-of blue-link-neighbors with [follower? = false][
              set waiting random 200 + 200
            ]
            set waiting [waiting] of following
            ask [blue-link-neighbors] of one-of link-neighbors [ set waiting [waiting] of following ]
          ]
          [
            set waiting random 200 + 200
            ask blue-link-neighbors [ set waiting [waiting] of following ]
          ]
        ]
      ]
      ;; Only start to move if it is the person leading the group or if the person leading the group is no longer waiting
      following = 0 or [waiting] of following <= 0 [
        check-clear
        ifelse clear? [
          ifelse follower? = false or friends? = false [move-out]
          [follow-guide-out] ;; for those students following they get some extra steps before moving out
        ]
        [
          if clear3? and xcor = 1 or xcor = (room-width - 1) [ ;; If it is already at the edge of the room it finish its movement by going out of the room
            set clear4? true
            set heading 180
            fd 1
            die
          ]
        ]
      ])
    ]
    )
    ;; Decreasing the time waiting and waiting to ask the next-question each tick that goes by
    set waiting waiting - 1
    set next-question next-question - 1
  ]
  set seated count students with [chair-number = chair-num]
end

;; Function moves the students to their corresponding seat, that being at the beginning of class or after the demonstration finishes
to move-to-seat
  (ifelse clear1? = false [  ;; First part brings them one step forward and heads them in the appropriate direction
    fd 1
    set target patch (item pathway-x pathways-xcor + random extra) ycor  ;; Target will be one of the patches in the hallway corresponding to their lab table
    face target
    ;; If a student is a follower and the ticks correspond to the entrance times
    if friends? and follower? and ticks < (2000 + introduction-time * 400) and [clear2?] of following = false [
      ;; Setting up the target in the corresponding position in relative to the target of the student its following
      set heading [heading] of following
      let main-target [target] of following
      let new-target main-target
      if follow-position != 3 [
        ask main-target [set new-target patch-at-heading-and-distance ((round (([follow-position] of myself) / 1.5)) * 90) 1 ]
      ]
      set target new-target
      ;; Moving to the patch corresponding to the position around the student it's following
      ifelse abs (follow-position) > 1 [ ;; For those moving a few steps behind the student their following
        let move-into NOBODY
        ifelse follow-position = 3 [
          set move-into [patch-here] of following
        ]
        [
          set move-into [patch-right-and-ahead ((round (([follow-position] of myself) / 1.5)) * 90) 1] of following
        ]
        ifelse heading = 90 [
          move-to patch ([pxcor] of move-into - 2) ([pycor] of move-into)
        ]
        [ move-to patch ([pxcor] of move-into + 2) ([pycor] of move-into) ]
      ]
      [ move-to [patch-right-and-ahead (([follow-position] of myself) * 90) 1]  of following ]
    ]
    set clear1? true
    ]
    ;; Second part (clear2? = false) moves the students to the pathway they'll take to reach their lab table
    clear2? = false [
      check-clear
      if clear? [
        ifelse distance target <= 1 [ ;; Once they reach their target they reset the target and move to the next step
          move-to target
          set clear2? true
          ;; Setting up the targets for the next step of the movement
          (ifelse location = 2 [
            set target patch xcor ([pycor] of target-patch)  ;; For the students at the edges of the table
            ]
            location = 1 [
              set target patch xcor ([pycor] of target-patch - 1)    ;; Students at the lower side of the seats
            ]
            location = 3 [
              set target patch xcor ([pycor] of target-patch + 1)   ;; Students at the upper side of the seats
            ]
          )
          face target
        ]
        [
          ;; Next two if statements help the student avoid the grey lab table when it's moving back to its seat after the demonstration
          if (patch-ahead 1 != NOBODY and ([pcolor != black] of patch-ahead 1) and avoiding? = false)[   ;; If it detects the grey table it'll change its direction to move around it
            let offset remainder heading 90
            let angle 0 - offset
            let i 0
            ;; While statement looking for the angle where there is no lab table in front
            while [i = 2 or ((i < 5) and (patch-right-and-ahead angle 1 = NOBODY or [pcolor != black] of patch-right-and-ahead angle 1))] [
              set angle angle + 90
              set i i + 1
            ]
            set heading (remainder (heading + angle) 360)
            set avoiding? true
          ]
          if avoiding? [  ;; When it is not moving directly to its target but going around the grey lab table
            let prev heading
            ;; Wall? is a function that reports true when there is a patch not equal to black in the angle its given as a parameter
            if patch-ahead 1 = NOBODY or (not wall? 90 and not wall? -90) [  ;; If it detects that it has reached the edge of the table it tries to move directly to its target again
              face target
              set avoiding? false
            ]
          ]

          ;; People with friends only move when the group is correctly walking together
          ifelse friends? and ticks < (2000 + introduction-time * 400)[
            ifelse heading = 90 [
              ;; Followers have to be behind the student its following to move
              if follower? and (xcor <= [xcor] of following or [clear2?] of following) [
                fd 1
              ]
              ;; Non-followers have to be at the same point as the students following him and has to have at least two follower beside him (one if they're only 2 in the group)
              if follower? = false and (count blue-link-neighbors with [clear1?] >= num-in-group - 1 or count blue-link-neighbors with [clear1?] >= 2) and xcor <= [xcor] of min-one-of blue-link-neighbors with [abs (follow-position) < 2][xcor][
                fd 1
              ]
            ]
            [
              ;; Followers have to be behind the student its following to move
              if follower? and (xcor >= [xcor] of following or [clear2?] of following) [
                fd 1
              ]
              ;; Non-followers have to be at the same point as the students following him and has to have at least two follower beside him (one if they're only 2 in the group)
              if follower? = false and (count blue-link-neighbors with [clear1?] >= num-in-group - 1 or count blue-link-neighbors with [clear1?] >= 2) and xcor >= [xcor] of max-one-of blue-link-neighbors with [abs (follow-position) < 2][xcor][
                fd 1
              ]
            ]
          ]
          [ fd 1 ]
        ]
      ]
    ]
    ;; Third part moves the students to the ycor where their seat is
    clear3? = false [
      ifelse distance target <= 1 [ ;; Once they reach their target they reset the target and move to the next step
        move-to target
        set clear3? true
        set heading 270
        set target target-patch
      ]
      [ check-clear  ;; Checking if its clear to move due to social-distancing
        if clear? [
          ifelse friends? and ticks < (2000 + introduction-time * 400) [  ;; For people in groups moving to their seat at the beginning of class
            if follower? [ ;; Followers move when they are not ahead of the student they are following
              if abs (follow-position) < 2 and (([clear2?] of following and ycor <= [ycor] of following) or [clear3?] of following) [fd 1]
              if abs (follow-position) > 1 and (([clear2?] of following and ycor + 2 <= [ycor] of following) or [clear3?] of following) [fd 1] ;; Have to be two steps behind (positions -3, -2 and 2)
            ]
            ;; Non-followers have to be at the same point as the students following him and has to have at least two follower beside him (one if they're only 2 in the group)
            if follower? = false and (count blue-link-neighbors with [clear2?] >= num-in-group - 1 or count blue-link-neighbors with [clear2?] >= 2) and (count blue-link-neighbors with [abs (follow-position) < 2 and clear3? = false] = 0 or ycor <= [ycor] of min-one-of blue-link-neighbors with [abs (follow-position) < 2 and clear3? = false][ycor])[
              fd 1
            ]
          ]
          [ fd 1 ]
        ]
      ]
    ]
    ;; Fourth and final part moves students to their seats
    clear4? = false [
      ifelse distance target <= 1 [ ;; Once they are close enough to their seat they move to it
        set clear4? true
        face target
        move-to target
        if ticks < (2000 + introduction-time * 400) [
          face one-of instructors with [main?]
        ]
      ]
      [ fd 1 ]
    ]
  )
end

;; Function guides the students that follow a member of their group to their seats
to follow-guide
  (ifelse follow-position = 0 [ ;; First setting up their position to one of -1, 1, 3, -2, 2
    set follow-position first [positions-list] of following
    ask following [ set positions-list remove-item 0 positions-list ]
    if follow-position != 3 [
      move-to [patch-right-and-ahead ((round (([follow-position] of myself) / 1.5)) * 90) 1] of following ;; Moving to the patch corresponding to their position, left or right of the person their following
    ]
  ]
  ;; For students with follow position 3, -2, or 2 (the ones that walk a few steps behind the person their following).
  ;; This makes sure they are a few steps behind before proceeding to move-to-seat
  [clear1?] of following and abs (follow-position) > 1 and first? [
    if abs ([xcor] of following - xcor) >= 2 [
      set first? false
    ]
  ]
  [clear1?] of following [
    move-to-seat
  ])
end

;; Function moves the students to their new seat for a different section of the experiment
to change-seat
  (ifelse clear1? = false [ ;; Clear1 is used to move the instructors away from the table their at, moves them to a hallway
    ifelse distance target <= 1 [ ;; If its already close to its target
      move-to target
      set clear1? true
      ifelse xcor >= (item pathway-x pathways-xcor - 1) and xcor <= (item pathway-x pathways-xcor + extra) [ ;; If already in correct hallway set target to nearby ycor of seat
        set clear2? true  ;; Skips clear 2
        (ifelse location = 2 [
          set target patch xcor ([pycor] of target-patch)  ;; For the students at the edges of the table
        ]
        location = 1 [
          set target patch xcor ([pycor] of target-patch - 1)    ;; Students at the lower side of the seats
        ]
        location = 3 [
          set target patch xcor ([pycor] of target-patch + 1)   ;; Students at the upper side of the seats
        ]
        )
      ]
      [
        let remaining remainder (chair-num - 1) (chairs-per-table * number-of-rows)
        let lab (int (remaining / chairs-per-table) + 1)
        ifelse lab = 1 or lab = number-of-rows [  ;; Target above or below all lab tables if its next table is either in top or bottom row
          ifelse lab = number-of-rows [
            set target patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
          ]
          [ set target patch xcor (room-margin-y - 2) ]
        ]
        ;; Otherwise it goes up or down depending on what's closest
        [
          ifelse distance patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) < distance patch xcor (room-margin-y - 2) [
            set target patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
          ]
          [ set target patch xcor (room-margin-y - 2) ]
        ]
      ]
      face target
    ]
    [ fd 1 ]
  ]
  ;; Clear2 moves them to the bottom or top of the lab tables and to the hallway of the next demonstration
  clear2? = false [
    ifelse distance target <= 1 [ ;; If its already close to its target
      move-to target
      ;; If still not in correct hallway it sets target to correct hallway and doesn't clear this 2nd step yet
      ifelse xcor < (item pathway-x pathways-xcor - 1) or xcor > (item pathway-x pathways-xcor + extra) [
        set target patch (item pathway-x pathways-xcor - 1 + random (extra + 1)) ycor
      ]
      [
        ;; Setting target to ycor appropriate for target chair
        set clear2? true
        (ifelse location = 2 [
          set target patch xcor ([pycor] of target-patch)  ;; For the students at the edges of the table
        ]
        location = 1 [
          set target patch xcor ([pycor] of target-patch - 1)    ;; Students at the lower side of the seats
        ]
        location = 3 [
          set target patch xcor ([pycor] of target-patch + 1)   ;; Students at the upper side of the seats
        ]
        )
      ]
      face target

    ]
    [ fd 1 ]
  ]
  ;; Clear3 takes the instructors/TAs to the correct ycor of where they will do the demonstration
  clear3? = false [
    ifelse distance target <= 1 [ ;; If its already close to its target
      move-to target
      set clear3? true
      set target target-patch
      set heading 270
    ]
    [ fd 1 ]
  ]
  ;; Clear4 takes the instructors/TAs to the place where they'll do the demonstration
  clear4? = false [
    ifelse distance target <= 1 [ ;; If its already close to its target
      face target
      move-to target
      set clear4? true
      set change-seat? false
    ]
    [ fd 1 ]
  ]
  )
end

;; Function gets the student started in moving from one demonstration the another
to move-to-another-demonstration
  (ifelse clear1? = false [ ;; Clear 1 moves student to the closest hallway and then to the the top or bottom of all lab tables
    ifelse distance target <= 1 [ ;; If its already reaching its target
      move-to target
      let path int ((dem-lab-number-s - 1) / number-of-rows)
      ;; If in top or bottom of all lab tables it moves on to clear2
      ifelse ycor = (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) or ycor = (room-margin-y - 2) [
        set clear1? true
        ifelse dem-lab-number-s != 0 [ ;; If next demonstration not in top lab table
          ifelse xcor >= (item path pathways-xcor - 1) and xcor <= (item path pathways-xcor + extra) [ ;; If already in correct hallway of demonstration
            set target patch-here
          ]
          [ set target patch (item path pathways-xcor + random extra) ycor ] ;; Sets target to correct hallway of demonstration
        ]
        [ set clear2? true ] ;; If next demonstration is top lab table it skips clear2
      ]
      [
        ;; If already in correct hallway move on from clear 1
        ifelse xcor >= (item path pathways-xcor - 1) and pxcor <= (item path pathways-xcor + extra) and dem-lab-number-s != 0 [
          set clear1? true
          set target patch-here
        ]
        [
          ;; Setting target patch to either top or bottom of all lab tables depending on whether student is in top or bottom half of the previous demonstration
          ifelse ycor > [pycor] of one-of patches with [plabel = [prev-lab-number-s] of myself and pcolor != red] or dem-lab-number-s = 0 [
            set target patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
          ]
          [ set target patch xcor (room-margin-y - 2) ]
        ]
      ]
      face target
    ]
    [ check-clear
      if clear? [
        fd 1
      ]
    ]
  ]
  clear2? = false [ ;; Clear 2 moves the students to the correct hallway of the next demonstration
    ifelse distance target <= 1 [
      set clear2? true
      move-to target
      ifelse ycor = (room-margin-y - 2) [ ;; Setting the target to a few patches before the lab table of the demonstration
        set target patch xcor ([pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red] - round (table-height / 2) - row-space)
      ]
      [
        set target patch xcor ([pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red] + round (table-height / 2) + row-space)
      ]
      face target
    ]
    [ check-clear
      if clear? [
        ;; Next two if statements help the student avoid the grey lab table when it's moving back to its seat after the demonstration
        if (patch-ahead 1 != NOBODY and ([pcolor != black] of patch-ahead 1) and avoiding? = false)[   ;; If it detects the grey table it'll change its direction to move around it
          let offset remainder heading 90
          let angle 0 - offset
          let i 0
          ;; While statement looking for the angle where there is no lab table in front
          while [i = 2 or ((i < 5) and (patch-right-and-ahead angle 1 = NOBODY or [pcolor != black] of patch-right-and-ahead angle 1))] [
            set angle angle + 90
            set i i + 1
          ]
          set heading (remainder (heading + angle) 360)
          set avoiding? true
        ]
        if avoiding? [  ;; When it is not moving directly to its target but going around the grey lab table
          let prev heading
          ;; Wall? is a function that reports true when there is a patch not equal to black in the angle its given as a parameter
          if patch-ahead 1 = NOBODY or (not wall? 90 and not wall? -90) [  ;; If it detects that it has reached the edge of the table it tries to move directly to its target again
            face target
            set avoiding? false
          ]
        ]

        fd 1
      ]
    ]
  ]
  [
    move-to-demonstration
  ])
end

;; This function moves the students a demonstration around a lab table
to move-to-demonstration
  (ifelse clear1? = false [  ;; First part moves students one step out of their seats and facing the appropriate direction
      let path int ((dem-lab-number-s - 1) / number-of-rows)
      set clear1? true
      ifelse int ((chair-num - 1)/ chairs-per-table) + 1 = dem-lab-number-s [
        set clear2? true
        set clear3? true
        set clear4? true
        set clear5? true
        face one-of patches with [pcolor != red and plabel = [dem-lab-number-s] of myself]
        ask patch-here [set used? true ask neighbors with [pycor = [pycor] of myself][set used? true] ]
      ]
      [
        fd 1
        set target patch (item pathway-x pathways-xcor + random extra) ycor   ;; Target is now one of the xcor in the hallway at the current ycor
        set heading 90
      ]
    ]
    ;; Second part of movement takes students to the pathways/hallways (the space in between the lab columns)
    clear2? = false [
      check-clear
      if clear? [
        ifelse distance target <= 1 [
          move-to target
          let path int ((dem-lab-number-s - 1) / number-of-rows)
          set clear2? true
          ;; If already in correct hallway
          ifelse xcor >= (item path pathways-xcor - 1) and pxcor <= (item path pathways-xcor + extra) and dem-lab-number-s != 0 [
            set clear5? true
            ;; Setting the target to a few patches before the lab table of the demonstration
            ifelse ycor < [pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red][
              set target patch xcor ([pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red] - round (table-height / 2) - row-space)
            ]
            [ set target patch xcor ([pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red] + round (table-height / 2) + row-space) ]
          ]
          [
            ;; If not in correct hallway it sets target to either the top or bottom of all lab tables
            let remaining remainder (chair-num - 1) (chairs-per-table * number-of-rows)
            let lab (int (remaining / chairs-per-table) + 1)
            ifelse lab = 1 or lab = number-of-rows [  ;; If current lab table is in top or bottom rom
              ifelse lab = 1 and dem-lab-number-s != 0 [ ;; If in bottom row
                set target patch xcor (room-margin-y - 2)
              ]
              [ set target patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) ]
            ]
            [
              ;; Next target top or bottom of all lab tables depending on which one is closer to the next demonstration lab table
              ifelse ycor < [pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red] and dem-lab-number-s != 0 [
                set target patch xcor (room-margin-y - 2)
              ]
              [ set target patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) ]

            ]
          ]
          face target
        ]
        [ fd 1 ]
      ]
    ]
    clear5? = false [ ;; Clear 5 moves students to the top or bottom of all lab tables
      ifelse distance target <= 1 [
        move-to target
        let path int ((dem-lab-number-s - 1) / number-of-rows)
        (ifelse dem-lab-number-s = 0 [
          set clear5? true
        ]
        xcor >= (item path pathways-xcor - 1) and pxcor <= (item path pathways-xcor + extra) [  ;; If already in correct hallway
          set clear5? true
          ifelse ycor = (room-margin-y - 2) [ ;; Setting the target to a few patches before the lab table of the demonstration
            set target patch xcor ([pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red] - round (table-height / 2) - row-space)
          ]
          [ set target patch xcor ([pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red] + round (table-height / 2) + row-space) ]
          face target
        ]
        [
          ;; If not in correct hallway it doesn't clear step "5" and sets target to the correct hallway
          set target patch (item path pathways-xcor + random extra) ycor
          face target
        ])
      ]
      [ check-clear
        if clear? [fd 1]
      ]
    ]
    ;; Third part moves them above all lab tables
    clear3? = false [
      ifelse distance target <= 1 or count patches with [occupied? and pycor = [pycor] of ([target] of myself)] >= column-space [
        ;; This next part to setup the next target tries to give the students targets around the  lab table and as one "circle" around the lab table gets filled up it
        ;; assigns them a target in the next outer circle. It also tries to space them out so they are not as close together
        if distance target <= 1 [ move-to target ]
        let outer-circle NOBODY
        set clear3? true
        let w who
        set target min-one-of patches with [(pcolor = black or pcolor = red) and (count neighbors with [pcolor = (6 - position ([dem-lab-number-s] of turtle w) dem-labs)] > 0) and used? = false][distance myself] ;; First circle, right around the lab table
        if dem-lab-number-s != 0 [ set target min-one-of patches with [(pcolor = black or pcolor = red) and (count neighbors with [pcolor = (6 - position ([dem-lab-number-s] of turtle w) dem-labs)] > 0) and used? = false][pxcor] ]
        if target = NOBODY [  ;; In other words if the first circle is filled up
          if first-time? [ ;; First time this goes through it sets up the patches from the first circle and their neighbors to used and occupied so that they can't be assigned as targets anymore
            ask patches with [used? and occupied? = false and dem-lab-number-p = [dem-lab-number-s] of myself][
              set occupied? true
              ask neighbors with [pcolor = black][set occupied? true set used? true set dem-lab-number-p [dem-lab-number-s] of turtle w]
            ]
            set first-time? false
          ]
          set outer-circle patches with [(pcolor = black or pcolor = red) and (count neighbors with [occupied? and used? and dem-lab-number-p = [dem-lab-number-s] of turtle w] > 0) and used? = false]
          if count outer-circle = 0 [ ;; If the outer-circle is filled now, meaning all used? = true it marks them as occupied so it can move on to the next outer-circle
            ask patches with [used? and occupied? = false and dem-lab-number-p = [dem-lab-number-s] of myself][
              set occupied? true
              ask neighbors [set occupied? true set used? true set dem-lab-number-p [dem-lab-number-s] of turtle w]
            ]
            set outer-circle patches with [(pcolor = black or pcolor = red) and (count neighbors with [occupied? and used? and dem-lab-number-p = [dem-lab-number-s] of turtle w] > 0) and used? = false]
          ]
          ;; Setting target where student will look at demonstration from accordingly
          ifelse ycor = (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) or ycor = (room-margin-y - 2) [
            ifelse ycor = (room-margin-y - 2) [
              set target max-one-of outer-circle [pycor]
            ]
            [ set target min-one-of outer-circle [pycor] ]
          ]
          [ set target min-one-of outer-circle [distance myself] ]
          if dem-lab-number-s != 0 [
            set target min-one-of outer-circle [pxcor]
            let path int ((dem-lab-number-s - 1) / number-of-rows)
            if [pxcor] of target >= (item path pathways-xcor - 1) [
              ifelse count students with [ycor > [pycor] of one-of patches with [plabel = [dem-lab-number-s] of turtle w and pcolor != red]] > (number-of-students / 2) [
                set target min-one-of outer-circle [pycor]
              ]
              [
                set target min-one-of outer-circle [distance one-of patches with [plabel = [dem-lab-number-s] of turtle w and pcolor != red]]
              ]
            ]
          ]
        ]
        ask target [  ;; Setting the target to used along with its two side neighbors
          set used? true
          set dem-lab-number-p [dem-lab-number-s] of turtle w
          ask neighbors with [(pcolor = black or pcolor = red) and used? = false and (count neighbors with [occupied? and used?] > 0 or count neighbors with [pcolor = (6 - position ([dem-lab-number-s] of turtle w) dem-labs)] > 0)][set used? true set dem-lab-number-p [dem-lab-number-s] of turtle w]
        ]
        face target
        if dem-lab-number-s != 0 and [pycor] of target < [pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red] and [pycor] of target < ycor[
          set heading 180
        ]
        if dem-lab-number-s != 0 and [pycor] of target > [pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red] and [pycor] of target > ycor[
          set heading 0
        ]
      ]
      [ check-clear
        if clear? [fd 1]
      ]
    ]
    ;; Fourth part moves the students to their final target around the demonstration
    clear4? = false [
      if count students with [clear3?] = number-of-students [set first-time? true]
      ifelse distance target <= 1 [
        move-to target
        set clear4? true
        face one-of patches with [pcolor != red and plabel = [dem-lab-number-s] of myself]
        ;face patch (room-width / 2) (room-height - room-margin-y + -1.5) ;; Demonstration movement done, facing the center of the grey lab table now
      ]
      [
        ;; Next if statements help the student avoid the grey lab table and other students when it's moving to its spot where it'll watch the demonstration (its target)
        ;; student? is a function that reports true if there is a student in the inputed angle that is already set in its spot
        if (patch-ahead 1 != NOBODY and ([pcolor != black and pcolor != red] of patch-ahead 1 or student? 0))[ ;; If it detects the grey table or a student already set in its spot it'll change its direction to move around it
          let offset remainder heading 90
          let angle 0 - offset
          let i 0
          ;; While statement looking for the angle where there is no lab table or student in front
          while [i = 2 or ((i < 16) and (patch-right-and-ahead angle 1 = NOBODY or [pcolor != black and pcolor != red] of patch-right-and-ahead angle 1 or student? angle))] [
            ifelse i < 4 [
              set angle angle + 90
            ]
            [ set angle angle + 30 ]
            set i i + 1
          ]
          ;; If i = 5 it means it couldn't find an angle or a way around students to get to its spot so it just sets up a new target
          ifelse i = 16 [
            ask target [set occupied? false ask neighbors with [count students-here = 0 and count students-on neighbors = 0][set occupied? false]]
            set target min-one-of patches with [pcolor = black and occupied? = false and (count neighbors with [occupied?] > 0) and count turtles-here = 0][distance myself]
            ask target [set occupied? true ask neighbors [set occupied? true]]
            set avoidances 0
            face target
          ]
          [
            set heading (remainder (heading + angle) 360)
            set avoiding? true                ;; When student is moving around the lab table or other students rather than moving directly to its target it is "avoiding"
            set avoidances avoidances + 1     ;; Counting the times it changes direction in attempt to avoid
          ]
        ]
        if avoiding? [     ;; When it is not moving directly to its target but going around obstacles
          let prev heading
          ;; Wall? is a function that reports true when there is a patch not equal to black in the angle its given as a parameter
          if patch-ahead 1 = NOBODY or [pcolor != black and pcolor != red] of patch-ahead 1 or (not wall? 90 and not wall? -90 and not student? 90 and not student? 135 and not student? -90 and not student? -135) [ ;; If it detects that it has reached the edge of the table or a collection of students it tries to move directly to its target again
            face target
            set avoiding? false
          ]
          ;; This last if statement keeps the student from going back in the same direction or changing direction too much without getting anywhere.
          ;; If such things occur it changes its target to some target nearby
          ;; heading = remainder (prev + 180) 360 or
          if avoidances > 8 or ticks > (2000 + (introduction-time + (demonstration-time * (z - 1))) * 400 + 400)[
            let w who
            ask target [set occupied? false ask neighbors with [count students-here = 0 and count students-on neighbors = 0][set occupied? false]]
            set target min-one-of patches with [pcolor = black and occupied? = false and (count neighbors with [occupied?] > 0 or count neighbors with [pcolor = (6 - position ([dem-lab-number-s] of turtle w) dem-labs)] > 0) and count turtles-here = 0][distance myself]
            ask target [set occupied? true ask neighbors [set occupied? true]]
            if ticks > (2000 + (introduction-time + (demonstration-time * (z - 1))) * 400 + 400) or (dem-lab-number-s != 0 and count other students-here = 0 and count other students-on neighbors < 2 and number-of-students > chairs-per-table * 7) [
              set target patch-here
              face one-of patches with [pcolor != red and plabel = [dem-lab-number-s] of myself]
            ]
            set avoidances 0
            face target
          ]
        ]
        if (heading = 180 or heading = 0) and ycor = [pycor] of target [
          face target
        ]
        if patch-ahead 1 != NOBODY and [pcolor = black or pcolor = red] of patch-ahead 1 [
          fd 1
        ]
      ]
    ]
  )
end

;; This function is for the extra-movement required in some cases when going back to seat after the demonstration
;; This is when students are NOT in some ycor above all the lab tables (they're in a hallway per say).
;; They get a target assigned previously which is their current ycor and one of the xcor of the closest lab hallway in case of being in the correct hallway
;; Otherwise its target was assigned to the ycor above all lab tables
to extra-movement
  ifelse distance target <= 1 [
    move-to target
    ;; If it approached the ycor above all lab tables it is sets the target to the hallway in its corresponding lab table
    (ifelse ycor = (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) or ycor = (room-margin-y - 2 )[
      set target patch (item pathway-x pathways-xcor + random extra) ycor
      set extra-movement? false
    ]
    ((pathway-x = 0) or xcor >= ((item pathway-x pathways-xcor) - 1)) and xcor <= ((item pathway-x pathways-xcor) + extra) [ ;; If in correct hallway
      ;; Setting up the targets for the next step of the movement
      (ifelse location = 2 [
        set target patch xcor ([pycor] of target-patch)  ;; For the students at the edges of the table
        ]
        location = 1 [
          set target patch xcor ([pycor] of target-patch - 1)    ;; Students at the lower side of the seats
        ]
        location = 3 [
          set target patch xcor ([pycor] of target-patch + 1)   ;; Students at the upper side of the seats
        ]
      )
      set clear2? true ;; Skipping clear2? step in the move-to-seat function
      set extra-movement? false
    ]
    [
      ifelse dem-lab-number-s = 99 [ ;; If going to seat
        ;; Set target to whichever is closest to seat
        ifelse ycor < [pycor] of one-of patches with [plabel = ( int ( ( ([chair-num] of myself) - 1) / chairs-per-table) + 1) and pcolor != red][
          set target patch xcor (room-margin-y - 2)
        ]
        [ set target patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) ]
      ]
      [
        ;; Set target to whichever is closest to next demonstration lab table
        ifelse ycor < [pycor] of one-of patches with [plabel = [dem-lab-number-s] of myself and pcolor != red][
          set target patch xcor (room-margin-y - 2)
        ]
        [ set target patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) ]
      ]
    ])
    face target
  ]
  [
    fd 1
  ]
end

;; Function guides the follower students out of the room (following one person in the group)
to follow-guide-out
  (ifelse clear1? = false [  ;; Clear1? step is followed first as the student is walking independently at this point
    move-out
  ]
  follow-position = 0 [  ;; Once clear1? step is cleared it sets up its follow-position (-1 1 3 -2 or 2) and its target patch in the hallway
    let main-target [target] of one-of blue-link-neighbors with [follower? = false]
    if [pxcor] of main-target >= (item pathway-x pathways-xcor) and [pxcor] of main-target <= (item pathway-x pathways-xcor + extra + 1) [
      set follow-position first [positions-list] of following
      ask following [ set positions-list remove-item 0 positions-list ]
      let new-target main-target
      if follow-position != 3 [  ;; Hallway patch target is set based on its follow position (if its 3 it is the same as it is in the same xcor but simply two steps behind)
        ask main-target [set new-target patch-at-heading-and-distance ((round (([follow-position] of myself) / 1.5)) * -90) 1]
      ]
      set target patch [pxcor] of new-target ycor
    ]
  ]
  clear1? [  ;; Once the other two conditions have been passed it can continue to the move-out function as it is
    move-out
  ]
  )
end

to move-out
  (ifelse clear1? = false [  ;; First part moves students one step out of their seats and facing the appropriate direction (90 deg)
    rt 180
    fd 1
    set clear1? true
    set target patch (item pathway-x pathways-xcor + random extra) ycor
    set heading 90
    ]
    ;; Second part of movement takes students to the pathways (the space in between the lab columns)
    clear2? = false [
      ifelse distance target <= 1 [
        if friends? = false or follower? = false or abs (follow-position) < 2 or (ycor - [ycor] of following) >= 2 [
          move-to target
          if follower? or (count blue-link-neighbors with [clear2? = false and location = [location] of myself and abs (follow-position) < 2] = 0)[
            set clear2? true   ;; Only moves on to next step if it has already waited for person in group and in same seat location to be beside them
          ]
          set heading 180
          while [friends? and follower? and location = [location] of following and [clear2?] of following and distance following > 2] [fd 1]
        ]
      ]
      [ ifelse friends? and follower? [
          ifelse location = [location] of following [ ;; Same seat position (upper or lower)
            ifelse abs (follow-position) < 2 [fd 1]
            [
              ;; If follow position (3 -2 or 2) meaning he'll walk a few steps behind, student only moves when they're two steps behind the person being followed
              if (distance target - [distance target] of following >= 2) or (distance target + (ycor - [ycor] of following) >= 2) [fd 1]
            ]
          ]
          [
            ;; For students not in the same seat "location"
            let dist 0
            let boolean false
            ask following [set dist distance (patch xcor ([ycor] of myself)) set boolean clear2?]
            if abs (follow-position) > 1 [   ;; Again if they should walk a few steps behind they should be some distance behind
              ifelse ycor <= [ycor] of following [
                set dist dist + 2
              ]
              [ set dist ycor - [ycor] of following ]
            ]
            if (boolean and distance target >= dist) or (boolean = false and distance target > dist) [ fd 1 ]
          ]
        ]
        [ fd 1 ]
      ]
    ]
    ;; Third part moves them down the the bottom of the room
    clear3? = false [
      ifelse ycor = 1 [
        ifelse xcor < (room-width / 2) or xcor = room-width [  ;; Takes the closest exit
          set heading 270
        ]
        [ set heading 90 ]
        ifelse friends? and follower? [
          if [clear3?] of following [  ;; They can only clear this step if the person they're following has also cleared it
            ifelse abs (follow-position) > 1 [ ;; If they should walk a few steps behind
              let move-into NOBODY
              ifelse follow-position = 3 [
                set move-into [patch-here] of following
              ]
              [
                set move-into [patch-right-and-ahead ((round (([follow-position] of myself) / 1.5)) * 90) 1] of following
              ]
              ;; This next if else moves them to their corresponding position patch 2 steps behind the preson they're following
              ifelse heading = 90 [
                move-to patch ([pxcor] of move-into - 2) ([pycor] of move-into)
              ]
              [ move-to patch ([pxcor] of move-into + 2) ([pycor] of move-into) ]
            ]
            ;; For those with positions -1 or 1 they're just moved to the patch beside the person they're following
            [ move-to [patch-right-and-ahead (([follow-position] of myself) * 90) 1]  of following ]
            set clear3? true
          ]
        ]
        [ set clear3? true ] ;; Non friends or followers clear this step here
      ]
      [ ifelse friends? [
          (ifelse follower? = false and location = 2 [ ;; People with friends and leading a group and are in the seat with on the side (the extra-chair)
            ;; Will only move if they're above their other group members (which can only have location 1 given that the upper most student is always the one being followed)
            ;; or if their group members are already beside him
            if count blue-link-neighbors with [clear2? and location = 1] = num-in-group - 1 or ycor > [ycor] of max-one-of blue-link-neighbors [ycor] [fd 1]
          ]
          (follower? and [clear2?] of following and ycor >= [ycor] of following) or (follower? = false and (count blue-link-neighbors with [location = [location] of myself and abs (follow-position) < 2] = 0 or [clear2?] of one-of blue-link-neighbors with [location = [location] of myself])) [
            ;; Students will move if they're a follower and the person they're following has cleared step 2 and if their ycor is equal or greater than the person they're following
            ;; They'll also move if they're not a follower and the student(s) that are supposed to be beside him already are
            fd 1
          ])
        ]
        [ fd 1 ]
      ]
    ]
    ;; Fourth part moves the students to the side doors and out of the room
    clear4? = false [
      ifelse xcor <= 1 or xcor >= (room-width - 1) [
        set clear4? true
        set heading 180
        while [ycor != 0] [fd 1]
        set color [255 0 0 0]
      ]
      [
        ifelse friends? [
          ifelse heading = 90 [
            if follower? [
              if (abs (follow-position) < 2 and xcor <= [xcor] of following) or [clear4?] of following [fd 1]  ;; Followers have to be behind or at the same xcor than the leader
              if (abs (follow-position) > 1 and (xcor + 2 <= [xcor] of following)) or [clear4?] of following [fd 1] ;; Followers in the back have to be 2 stepas behind than the leader
            ]
            if follower? = false and (count blue-link-neighbors with [clear3?] >= num-in-group - 1  or count blue-link-neighbors with [clear2?] >= 2) and xcor <= [xcor] of min-one-of blue-link-neighbors with [abs (follow-position) < 2][xcor][
              ;; Non-followers have to have their group members beside them so that they keep moving i.e they can't get too ahead of them
              fd 1
            ]
          ]
          [
            if follower? and xcor >= [xcor] of following [
              if (abs (follow-position) < 2 and xcor >= [xcor] of following) or [clear4?] of following [fd 1]  ;; Followers have to be behind or at the same xcor than the leader
              if (abs (follow-position) > 1 and xcor - 2 >= [xcor] of following) or [clear4?] of following [fd 1]  ;; Followers in the back have to be 2 stepas behind than the leader
            ]
            if follower? = false and (count blue-link-neighbors with [clear3?] >= num-in-group - 1 or count blue-link-neighbors with [clear2?] >= 2) and xcor >= [xcor] of max-one-of blue-link-neighbors with [abs (follow-position) < 2][xcor][
              ;; Non-followers have to have their group members beside them so that they keep moving i.e they can't get too ahead of them
              fd 1
            ]
          ]
        ]
        [ fd 1 ]
      ]
    ]
  )
end

;;;MOVEMENT OF INSTRUCTORS AND ITS FUNCTIONS;;;-------------------------------------------------------------------------------------------------------------------------------------

;; Responsible for the movement of all instructors/TAs depending on the time and the movement its already completed, calls other functions.
to move-instructors
  if count instructors with [walking-around? = false and question? = false and go-back? = false] != 0 [ ;; If it has nothing to do it checks if there is a question or if it should walk around
    check-for-question
  ]

  ask instructors [
    check-for-contact
    ;; Sets up variables for the demonstration
    if demonstration? and ticks = (2000 + (introduction-time + (demonstration-time * (z - 1))) * 400 + 1) [
      ifelse fraction-students-per-dem <= 1 [ ;; If only one group of students moving around demonstrations
        ;; Non-main instructors will move to "edges" to avoid student, main instructor will move around from demonstration to demonstration
        ifelse main? = false [
          ifelse dem-lab-number-i = 0 [ ;; If demonstration is in top lab table
            ifelse (xcor > 5 and xcor < room-width - 5) [
              ;; For non-main instructors target is set up to one of the patches in the edge (5 columns of patches right or left of the room) that is the furthest away from another instructor
              ifelse xcor < (room-width / 2) [ set target max-one-of patches with [pxcor < 5 and pycor >= (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))][distance (min-one-of other instructors [distance myself])] ]
              [ set target max-one-of patches with [pxcor > room-width - 5 and pycor >= (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))][distance myself] ]
              face target
              set clear1? false
            ]
            [ face one-of instructors with [main?] ]
          ]
          [
            ifelse ycor < room-width - room-margin-y - 3 [
              ;; For non-main instructors target is set up to one of the patches in the edge (5 columns of patches right or left of the room) that is the furthest away from another instructor
              set target min-one-of patches with [count other instructors in-radius social-radius = 0 and pycor > (room-height - room-margin-y - 4) and pcolor = black][distance myself]
              face target
              set clear1? false
            ]
            [ face one-of instructors with [main?] ]
          ]
        ]
        [
          ;; Updating variables for main instructor to move to demonstration
          ;; If first dem lab is not the top one or if it is not the first demonstration, it'll move around
          if (dem-lab-number-i != 0 and z = 1) or (z != 1 and fraction-students-per-dem <= 1) [
            set clear2? false
            set clear3? false
            set clear4? false
            ifelse xcor = (room-width / 2) and ycor = (room-height - room-margin-y + 1)[ ;; Coordinates of above the top lab table
              ;; Setting target to the appropriate hallway patch, will skip clear1 step in this case
              let path int ((dem-lab-number-i - 1) / number-of-rows)
              set target patch (item path pathways-xcor + random extra) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            ]
            [
              set clear1? false
              let section number-of-columns - 1
              let i 0
              while [section = number-of-columns - 1 and i < number-of-columns ][ ;; Getting what part of the student is currently at (what lab column)
                if xcor <= ((item i pathways-xcor) + extra + 1) [
                  set section i
                ]
                set i i + 1
              ]
              set target min-one-of patches with [ pxcor >= (item section pathways-xcor - 1) and pxcor <= (item section pathways-xcor + extra) ][distance myself]
            ]
            face target
            let w who
            ;; The following lines will set the saved-spot of the instrcutor for the demonstration
            ;; Will either put the saved spot on the top or bottom edge of the demonstration lab table
            ifelse dem-lab-number-i = 0 [ ;; Demonstration in top lab table, saved-spot right above it
              set saved-spot min-one-of patches with [pxcor = ([pxcor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and pycor > ([pycor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and (pcolor = black or pcolor = red)][pycor]
            ]
            [
              let prev-lab remainder prev-lab-number-i number-of-rows
              let next-lab remainder dem-lab-number-i number-of-rows
              (ifelse xcor = (room-width / 2) and ycor = (room-height - room-margin-y + 1) [ ;; If in patch above top lab table
                ;; Saved-spot set to top edge of the demonstration lab table
                set saved-spot min-one-of patches with [pxcor = ([pxcor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and pycor > ([pycor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and (pcolor = black or pcolor = red)][pycor]
                ]
                (prev-lab = 1 and heading = 0) [ ;; If previous demonstration lab is on bottom row and instructor on bottom edge
                  ;; Saved-spot set to bottom edge of the demonstration lab table
                  set saved-spot max-one-of patches with [pxcor = ([pxcor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and pycor < ([pycor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and (pcolor = black or pcolor = red)][pycor]
                ]
                (prev-lab = 0 and heading = 180) [ ;; If previous demonstration lab is on top row and instructor on top edge
                  ;; Saved-spot set to top edge of the demonstration lab table
                  set saved-spot min-one-of patches with [pxcor = ([pxcor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and pycor > ([pycor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and (pcolor = black or pcolor = red)][pycor]
                ]
                next-lab = 1 [ ;; If next demonstration lab is on bottom row
                  ;; Saved-spot set to bottom edge of the demonstration lab table
                  set saved-spot max-one-of patches with [pxcor = ([pxcor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and pycor < ([pycor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and (pcolor = black or pcolor = red)][pycor]
                ]
                next-lab = 0 [ ;; If next demonstration lab is on top row
                  ;; Saved-spot set to top edge of the demonstration lab table
                  set saved-spot min-one-of patches with [pxcor = ([pxcor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and pycor > ([pycor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and (pcolor = black or pcolor = red)][pycor]
                ]
                ;; If it is closer to the top of all labs rather than the bottom of all labs
                distance patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) < distance patch xcor (room-margin-y - 2) [
                  ;; Saved-spot set to top edge of the demonstration lab table
                  set saved-spot min-one-of patches with [pxcor = ([pxcor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and pycor > ([pycor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and (pcolor = black or pcolor = red)][pycor]
                ]
                [ ;; Saved-spot set to bottom edge of the demonstration lab table
                  set saved-spot max-one-of patches with [pxcor = ([pxcor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and pycor < ([pycor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and (pcolor = black or pcolor = red)][pycor] ]
              )
            ]
            ask saved-spot [ ;; Actually saving the patch so that no other student takes that spot
              set used? true
              ask neighbors with [(pcolor = black or pcolor = red) and used? = false and count neighbors with [pcolor = (6 - position [dem-lab-number-i] of turtle w dem-labs)] > 0][set used? true]
            ]
          ]
        ]
      ]
      ;; If multiple demonstration groups of students, instructors will each take a demonstration lab table and stay there
      [
        let w who
        ifelse main? = false [ ;; Non-main students will move to demonstration lab table
          if m < number-of-demonstrations [
            set clear2? false
            set clear3? false
            set clear4? false
            set dem-lab-number-i item m dem-labs
            if dem-lab-number-i = 0 [ ;; If demonstration lab table is top lab it replaces it as the top lab is given to the main instructor
              set dem-lab-number-i item 0 dem-labs
            ]
            let path int ((dem-lab-number-i - 1) / number-of-rows)
            ;; Setting target to patch in correct hallway
            set target min-one-of patches with [ pxcor >= (item path pathways-xcor - 1) and pxcor <= (item path pathways-xcor + extra) ][distance myself]
            face target
            ;; Setting saved-spot to top edge of the demonstration lab table
            set saved-spot min-one-of patches with [pxcor = ([pxcor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and pycor > ([pycor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and (pcolor = black or pcolor = red)][pycor]
            ask saved-spot [ ;; Actually saving the spot so a student doesn't go there
              set used? true
              ask neighbors with [(pcolor = black or pcolor = red) and used? = false and count neighbors with [pcolor = (6 - position [dem-lab-number-i] of turtle w dem-labs)] > 0][set used? true]
            ]
            set m m + 1
          ]
        ]
          ;; Main instructor will move to demonstration if top lab is not part of a demonstration
        [
          if position 0 dem-labs = false [ ;; If lab 0 (top lab) is not part of a demonstration
            set clear2? false
            set clear3? false
            set clear4? false
            set dem-lab-number-i item 0 dem-labs
            let path int ((dem-lab-number-i - 1) / number-of-rows)
            ;; Setting target to patch in correct hallway
            set target min-one-of patches with [ pxcor >= (item path pathways-xcor - 1) and pxcor <= (item path pathways-xcor + extra) ][distance myself]
            face target
            ;; Setting saved-spot to top edge of the demonstration lab table
            set saved-spot min-one-of patches with [pxcor = ([pxcor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and pycor > ([pycor] of one-of patches with [plabel = [dem-lab-number-i] of turtle w and pcolor != red]) and (pcolor = black or pcolor = red)][pycor]
            ask saved-spot [ ;; Actually saving the spot so a student doesn't go there
              set used? true
              ask neighbors with [(pcolor = black or pcolor = red) and used? = false and count neighbors with [pcolor = (6 - position [dem-lab-number-i] of turtle w dem-labs)] > 0][set used? true]
            ]
          ]
        ]
      ]
    ]
    (ifelse demonstration? and ticks > (2000 + introduction-time * 400) and ticks < (2000 + (introduction-time + (demonstration-time * z)) * 400 + 1) [
      ifelse main? = false [
        if z = 1 and saved-spot != 0 [move-to-demonstrate] ;; Non-main instructors moving to a demonstration at the beginning if necessary
        if saved-spot = 0 [move-to-edge] ;; Non-main instructors move to the edges of the room to not interfere with the students walking up to the demonstration
      ]
      [ if (dem-lab-number-i != 0 and z = 1) or (z != 1 and fraction-students-per-dem <= 1) [move-to-demonstrate] ] ;; Main instructor moving to demonstrations when necessary
    ]
    demonstration? and ticks = (2000 + (introduction-time + (demonstration-time * demonstrations)) * 400 + 1) and dem-lab-number-i != 0 [ ;; After all demonstrations are finished
      if saved-spot != 0 [ ;; Setting up variables for going back to top of room if instructor is at a demonstration
        rt 180
        fd 1
        set heading 90
        set clear1? false
        set clear2? false
        set clear3? false
        set go-back? true
        set steps int (table-width / 2) + 3
      ]
    ]
    demonstration? and ticks < (2000 + (introduction-time + (demonstration-time * demonstrations) + 1) * 400) and dem-lab-number-i != 0 [
      if saved-spot != 0 [ go-back ] ;; Going back to top of the room if necessary
    ])

    ;; If there's a question to answer
    if question? [
      ifelse clear4? = false [  ;; Means it's should still be moving to the question
        move-to-question
      ]
      [
        if answering <= 0 [ ;; If answering time is done
          ask students with [ int ((chair-num - 1) / chairs-per-table) = int (([target-chair] of myself - 1) / chairs-per-table) ] [
            ;; Variables for student changed to no question, now it'll wait to ask another question in case of having one
            set next-question random 3200 + 800
            set color blue
            if infected? [set color pink]
            set question? false
            set attended? false
          ]
          set heading 90
          set question? false
          another-question   ;; Checks if there is another question to go to answer
        ]
        set answering answering - 1
      ]
    ]

    ;; Goes back to upper part of the room if there is no further questions
    if go-back? [
      go-back
    ]
  ]
end

to move-to-demonstrate
  (ifelse clear1? = false [ ;; Clear1 is used to move the instructors away from the table their at, moves them to a hallway
    ifelse distance target <= 1 [ ;; If its already close to its target
      move-to target
      set clear1? true
      let path int ((dem-lab-number-i - 1) / number-of-rows)
      ifelse xcor >= (item path pathways-xcor - 1) and xcor <= (item path pathways-xcor + extra) [ ;; If already in correct hallway
        set clear2? true ;; Skips clear 2 step
        ;; Setting up target ycor depending on whether it'll give demonstration from top or bottom edge of the demonstration table
        ifelse ycor < [pycor] of one-of patches with [plabel = [dem-lab-number-i] of myself and pcolor != red] [
          set target patch xcor ([pycor] of saved-spot - 1)
        ]
        [ set target patch xcor ([pycor] of saved-spot + 1) ]
      ]
      [
        ;; Setting up target to top or bottom of all lab tables depending on whether it'll give demonstration from top or bottom edge of the demonstration table
        ifelse [pycor] of saved-spot > [pycor] of one-of patches with [plabel = [dem-lab-number-i] of myself and pcolor != red] [
          set target patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
        ]
        [ set target patch xcor (room-margin-y - 2) ]
      ]
      face target
    ]
    [ fd 1 ]
  ]
  ;; Clear2 moves them to the bottom or top of the lab tables and to the hallway of the next demonstration
  clear2? = false [
    ifelse distance target <= 1 [ ;; If its already close to its target
      move-to target
      let path int ((dem-lab-number-i - 1) / number-of-rows)
      ifelse xcor < (item path pathways-xcor - 1) or xcor > (item path pathways-xcor + extra) or dem-lab-number-i = 0 [ ;; If NOT in correct hallway or demonstration is in top lab table
        ifelse dem-lab-number-i = 0 [ ;; If demonstration is in top table it'll move on from clear 2 and skip clear 3 and set target directly to its demonstration spot
          set clear2? true
          set clear3? true
          set target patch (room-width / 2) (room-height - room-margin-y + 1)
        ]
        [ set target patch (item path pathways-xcor - 1 + random (extra + 1)) ycor ] ;; Otherwise it'll go to the correct hallway
      ]
      [
        ;; If it is in the correct hallway it'll move on from clear 2 and set target ycor depending on whether it'll give demonstration from top or bottom edge of the demonstration table
        set clear2? true
        ifelse ycor < [pycor] of saved-spot [
          set target patch xcor ([pycor] of saved-spot - 1)
        ]
        [ set target patch xcor ([pycor] of saved-spot + 1) ]
      ]
      face target

    ]
    [ if prev-lab-number-i = 0 [ ;; Next lines will make instructors avoid the top lab table given that they come from there
        if (patch-ahead 1 != NOBODY and ([pcolor != black] of patch-ahead 1) and avoiding? = false)[   ;; If it detects the grey table it'll change its direction to move around it
          let offset remainder heading 90
          let angle 0 - offset
          let i 0
          ;; While statement looking for the angle where there is no lab table in front
          while [i = 2 or ((i < 5) and (patch-right-and-ahead angle 1 = NOBODY or [pcolor != black] of patch-right-and-ahead angle 1))] [
            set angle angle + 90
            set i i + 1
          ]
          set heading (remainder (heading + angle) 360)
          set avoiding? true
        ]
        if avoiding? [  ;; When it is not moving directly to its target but going around the grey lab table
          let prev heading
          ;; Wall? is a function that reports true when there is a patch not equal to black in the angle its given as a parameter
          if patch-ahead 1 = NOBODY or (not wall? 90 and not wall? -90) [  ;; If it detects that it has reached the edge of the table it tries to move directly to its target again
            face target
            set avoiding? false
          ]
        ]
      ]

      fd 1
    ]
  ]
  ;; Clear3 takes the instructors/TAs to the correct ycor of where they will do the demonstration
  clear3? = false [
    ifelse distance target <= 1 [ ;; If its already close to its target
      move-to target
      set clear3? true
      set target saved-spot
      face target
    ]
    [ fd 1 ]
  ]
  ;; Clear4 takes the instructors/TAs to the place where they'll do the demonstration
  clear4? = false [
    ifelse distance target <= 1 [ ;; If its already close to its target
      move-to target
      set clear4? true
        face one-of patches with [plabel = [dem-lab-number-i] of myself and pcolor != red]
    ]
    [ if dem-lab-number-i = 0 [   ;; Next lines will make instructors avoid the top lab table given that they are heading to a demonstration there
        if (patch-ahead 1 != NOBODY and ([pcolor != black] of patch-ahead 1) and avoiding? = false)[   ;; If it detects the grey table it'll change its direction to move around it
          let offset remainder heading 90
          let angle 0 - offset
          let i 0
          ;; While statement looking for the angle where there is no lab table in front
          while [i = 2 or ((i < 5) and (patch-right-and-ahead angle 1 = NOBODY or [pcolor != black] of patch-right-and-ahead angle 1))] [
            set angle angle + 90
            set i i + 1
          ]
          set heading (remainder (heading + angle) 360)
          set avoiding? true
        ]
        if avoiding? [  ;; When it is not moving directly to its target but going around the grey lab table
          let prev heading
          ;; Wall? is a function that reports true when there is a patch not equal to black in the angle its given as a parameter
          if patch-ahead 1 = NOBODY or (not wall? 90 and not wall? -90) [  ;; If it detects that it has reached the edge of the table it tries to move directly to its target again
            face target
            set avoiding? false
          ]
        ]
      ]

      fd 1
    ]
  ]
  )
end

;; Function moves non-main instructors to the edges of the room during the time of demonstration (so that they don't interfere with students)
to move-to-edge
  if clear1? = false [
    ifelse distance target <= 1 [
      set clear1? true
      move-to target
      face one-of instructors with [main?]
      ;; If some other instructor is still in its social-radius it sets another target to a patch furthest away from any other instructor yet still close to the edge
      if first? and (count other instructors in-radius social-radius != 0 or (prev-lab-number-i = 0 and dem-lab-number-i > 0) or (prev-lab-number-i != 0 and dem-lab-number-i = 0)) [
        ifelse dem-lab-number-i = 0 [ ;; When demonstration is happening in top lab table they move to the right and left edges
          ifelse (xcor < room-width / 2) [
            set target min-one-of patches with [count other instructors in-radius social-radius = 0 and pycor > (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) and pcolor = black and pxcor < 7][distance myself]
          ]
          [ set target min-one-of patches with [count other instructors in-radius social-radius = 0 and pycor > (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) and pcolor = black and pxcor > room-width - 7][distance myself]]
          let n 2
          while [target = NOBODY] [
            ifelse (xcor < room-width / 2) [
              set target min-one-of patches with [count other instructors in-radius social-radius = 0 and pycor > (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) and pcolor = black and pxcor < 7 * n][distance myself]
            ]
            [ set target min-one-of patches with [count other instructors in-radius social-radius = 0 and pycor > (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) and pcolor = black and pxcor > room-width - n * 7][distance myself]]
            set n n + 1
          ]
        ]
        [ ;; When demonstration is NOT happening in top lab table they move to the top edges
          set target min-one-of patches with [count other instructors in-radius social-radius = 0 and pycor > (room-height - room-margin-y - 3) and pcolor = black][distance myself]
          let n 2
          while [target = NOBODY] [
            set target min-one-of patches with [count other instructors in-radius social-radius = 0 and pycor > (room-height - room-margin-y - 3 * n) and pcolor = black][distance myself]
            set n n + 1
          ]
        ]
        face target
        if count other instructors in-radius social-radius = 0 [ ;; If there is still someone in social radius they'll keep moving
          set first? false
        ]
        set clear1? false
      ]
    ]
    [ fd 1 ]
  ]
end

;; Function checks if a student has a question that hasn't been attended and sets up variables accordingly to answer said question
to check-for-question
  let inquiry students with [question? = true and attended? = false]  ;; Students with questions that haven't been attended
  if count inquiry != 0 [
    let targ one-of inquiry
    ask min-one-of instructors with [walking-around? = false and question? = false and go-back? = false][distance targ][  ;; If instructors aren't busy with anything else they check for questions or to walk around
      set question? true
      set clear1? false
      set clear2? false
      set clear3? false
      set clear4? false

      ;; Setting up the target chair
      set target-chair [chair-num] of targ
      set target-patch one-of patches with [chair-number = [chair-num] of targ]
      set pathway-x int ((target-chair - 1) / (chairs-per-table * number-of-rows)) ;; Which column the chair is on starting from 0
      ask targ [set attended? true]

      ;; Instructors/TAs located above the gray lab will have to make additional movements to avoid it
      ifelse pxcor < (room-width / 2 + 5) and pxcor > (room-width / 2 - 5) and pycor >= (room-height - room-margin-y + 1) [
        ;; Steps needed to be completed to avoid labs
        set steps (5 - abs (room-width / 2 - xcor))
        if main? and (int xcor) != xcor [set steps steps + 0.5]
        (ifelse xcor < (room-width / 2) [
          set heading 270
          ]
          xcor > (room-width / 2) [
            set heading 90
          ]
          [ifelse ([pxcor] of target-patch) > int (room-width / 2) [set heading 90] [set heading 270] ]
        )
      ]

      ;; Setting up the targets that'll bring them closer to the question they have to answer
      [
        set clear1? true  ;; Skips the first part of the moving-to-question
        ifelse xcor < (room-width / 2) [
          ifelse (item pathway-x pathways-xcor + extra) < xcor or (item pathway-x pathways-xcor + extra) <= int (room-width / 2 - 5) or (xcor > int (room-width / 2 - 5) and xcor < int (room-width / 2 + 5))[
            ;; Sets up target to one of the top patches in the hallway where the question is at
            set target patch (item pathway-x pathways-xcor + random extra) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            face target
          ]
          ;; If the pathway is across the grey table it just sets the target below the edge of the table
          [ set target patch (int (room-width / 2 - 5)) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            face target ]
        ]
        [
          ifelse (item pathway-x pathways-xcor) > xcor or (item pathway-x pathways-xcor) >= ceiling (room-width / 2 + 5) or (xcor > int (room-width / 2 - 5) and xcor < int (room-width / 2 + 5)) [
            ;; Sets up target to one of the top patches in the hallway where the question is at
            set target patch (item pathway-x pathways-xcor + random extra) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            face target
          ]
          ;; If the pathway is across the grey table it just sets the target below the edge of the table
          [ set target patch (ceiling (room-width / 2 + 5)) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            face target ]
        ]
      ]
    ]
  ]
end

;; Function checks if there is another question to be answered right after finishing answering a question. So that it goes straight to answering the question rather than back to the top of the room
to another-question
  let inquiry students with [question? = true and attended? = false]
  ifelse count inquiry != 0 [  ;; Setting up the variables for the next question target
    set question? true
    let targ one-of inquiry
    let previous target-chair
    set target-chair [chair-num] of targ
    set target-patch one-of patches with [chair-number = [chair-num] of targ]
    set pathway-x int ((target-chair - 1) / (chairs-per-table * number-of-rows))
    ask targ [set attended? true]
    set clear4? false
    set clear5? false   ;; Clear 5 and 6 are for when it moves from one question to the other only
    set clear6? false
    set steps 2
    ;; If question is on the same column it skips clear6 step and does the step in clear3
    if int ((target-chair - 1) / (chairs-per-table * number-of-rows)) = int ((previous - 1) / (chairs-per-table * number-of-rows)) [
      set clear6? true
      set clear3? false
    ]
  ]
  [
    ;; if no unattended questions it goes back to the upper part of the room
    set clear1? false
    set clear2? false
    set clear3? false
    set go-back? true
    set steps 2 + random extra
  ]
end

;; Function moves the instructor the the actual spot where (s)he will answer the question
to move-to-question
  ;; clear6? and clear5? are for moving directly from one question to another
  ifelse clear6? = false or clear5? = false [
    ifelse clear5? = false [  ;; clear5 step moves the instructors to the pathways in each column
      ifelse steps <= 0 [
        set clear5? true
        let y+diff (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1) - xcor)
        let y-diff xcor - room-margin-y - 2
        let remaining remainder (target-chair - 1) (chairs-per-table * number-of-rows)
        let lab (int (remaining / chairs-per-table) + 1)
        ifelse lab = 1 or lab = number-of-rows [  ;; faces up or down if the target lab table is either the first one or last one in a column
          ifelse lab = 1 [
            set heading 180
          ]
          [ set heading 0 ]
        ]
        ;; Otherwise it goes up or down depending on what's closest
        [
          ifelse y-diff < y+diff [
            set heading 180
          ]
          [
            set heading 0
          ]
        ]
        ;; Clear6? true when lab tables in the same column, sets up how many steps it has to move either up or down
        if clear6? [
          let diff abs ([pycor] of target-patch - ycor)
          let variable 0
          set remaining (remainder (target-chair - 1) (chairs-per-table * number-of-rows) + 1)
          let remaining2 remainder remaining chairs-per-table
          ifelse [pycor] of target-patch > ycor [
            set heading 0
            if remainder remaining chairs-per-table = 0 [  ;; If question at edge of the table it just takes the corner that is closest
              set diff abs ([pycor] of one-of patches with [chair-number = [target-chair] of myself - chairs-per-side - 1] - ycor)
            ]
          ]
          [ set heading 180
            if remainder remaining chairs-per-table = 0 [
              set diff abs ([pycor] of one-of patches with [chair-number = [target-chair] of myself - 1] - ycor)
            ]
          ]
          set steps diff + variable
        ]
      ]
      [ fd 1
        set steps steps - 1
      ]
    ]
    ;; The following clear6 step moves the instructor either to the top or the bottom of all rows of labs
    [
      ifelse ycor = (room-margin-y - 2) or ycor = (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) [
        set clear6? true
        set target patch (item pathway-x pathways-xcor + random extra) ycor
        face target
        set clear2? false
        set clear3? false
      ]
      [ fd 1 ]
    ]
  ]
  [
    (ifelse clear1? = false [ ;; Clear1 is used to move the instructors away from the grey table only, sets up the target once done
      ifelse steps <= 0 [
        set clear1? true
        ;; Same procedure as in check-for-question to setup the target
        ifelse xcor < (room-width / 2) [
          ifelse (item pathway-x pathways-xcor + extra) < xcor or (xcor > int (room-width / 2 - 5) and xcor < int (room-width / 2 + 5))[
            set target patch (item pathway-x pathways-xcor + random extra) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            face target
          ]
          [ set target patch (int (room-width / 2 - 5)) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            face target ]
        ]
        [
          ifelse (item pathway-x pathways-xcor) > xcor or (xcor > int (room-width / 2 - 5) and xcor < int (room-width / 2 + 5))[
            set target patch (item pathway-x pathways-xcor + random extra) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            face target
          ]
          [ set target patch (ceiling (room-width / 2 + 5)) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            face target ]
        ]
      ]
      [ fd 1
        set steps steps - 1
      ]
      ]
      ;; Clear2 moves them to the pathway / column where the target lab table is at
      clear2? = false [
        ifelse (target != NOBODY and distance target < 1.5) [ ;; If its already close to its target
          set clear2? true
          set heading 0
          move-to target
          let remaining (remainder (target-chair - 1) (chairs-per-table * number-of-rows) + 1)
          let labs int ((remaining - 1) / chairs-per-table)
          ;; For the instructors that are at the top of all the labs rather than the bottom (as some that go from question to question could be),
          ;; they need different remaining and labs variables to match, heading should be going down too
          if ycor = (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) [
            set remaining ((chairs-per-table * number-of-rows) - (remainder (target-chair - 1) (chairs-per-table * number-of-rows) + 1))
            set labs int (remaining / chairs-per-table)
            set heading 180
          ]
          let remaining2 remainder remaining chairs-per-table
          (ifelse remainder remaining chairs-per-table = 0 or int ((remaining2 - 1) / (chairs-per-side)) = 0 [ ;; For the side of the chairs closest to the instructor or the edge
            set steps (3 + (labs * table-height) + (row-space * labs))
            ]
            int ((remaining2 - 1) / (chairs-per-side)) = 1 [ ;; For the side of the chairs that is farthest to the instructor in the lab table
              set steps (4 + ((labs + 1) * table-height) + (row-space * labs))
            ]
          )
          ;; If the xcor is not that desired of the pathway in the column it sets up a target again and does clear2 again.
          ;; This is for those instructors that were blocked by the grey table and had to do it in two steps
          if xcor < (item pathway-x pathways-xcor) or xcor > (item pathway-x pathways-xcor + extra - 1)[
            set target patch (item pathway-x pathways-xcor + random extra) (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
            face target
            set clear2? false
          ]
        ]
        [ fd 1 ]
      ]
      ;; Clear3 takes the instructors/TAs to the correct ycor and then makes them face the right direction
      clear3? = false [
        ifelse steps <= 0 [
          set clear3? true
          set heading 270
          set steps 2 + xcor - (item pathway-x pathways-xcor)
        ]
        [ fd 1
          set steps steps - 1
        ]
      ]
      ;; Clear4 takes the instructors/TAs to the corner of the table closest to the student asking the question and sets up the time it's going to take to answer the question
      clear4? = false [
        ifelse steps <= 0 [
          set clear4? true
          face one-of neighbors with [pcolor = white]
          let ticks-till-change 0
          if number-of-sections > 1 [
            set ticks-till-change (ticks - 2000 - ((introduction-time + (demonstration-time * number-of-demonstrations)) * 400))
            if ticks-till-change > time-per-section [
              set ticks-till-change remainder ticks-till-change time-per-section
            ]
            set ticks-till-change (time-per-section - ticks-till-change)
          ]
          set answering 400 + random (avg-answering-time * 400 * 2 - 400)
          if number-of-sections > 1 and answering > ticks-till-change and (lab-time * 400 + 2000) - ticks > time-per-section [
            set answering random ticks-till-change
          ]
        ]
        [ fd 1
          set steps steps - 1
        ]
      ]
    )
  ]
end

;; Function moves the instructors to the top of the room after they've answered a question and have no other questions to answer
to go-back
  (ifelse clear1? = false [  ;; First step of going back takes them to the pathways and sets the ycor right above the end of all the lab tables as the target
    ifelse steps <= 0 [
      set clear1? true
      set heading 0
      set target patch xcor (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1))
    ]
    [ fd 1
      set steps steps - 1 ]
    ]
    ;; Takes them right above all lab tables and sets the next target as some random black patch at the upper part that respects the social-radius measures
    clear2? = false [
      ifelse (target != NOBODY and distance target < 1.5) [
        set clear2? true
        move-to target
        set target min-one-of patches with [count other instructors in-radius social-radius = 0 and pycor > (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) and pcolor = black][distance myself]
        face target
      ]
      [ fd 1 ]
    ]
    ;; Moves them to their final place while there is no questions and facing the classroom
    clear3? = false [
      ifelse (target != NOBODY and distance target < 1.5) [
        set avoiding? false
        move-to target
        set heading 180
        ;; If it still isn't within a social-radius of another instructor it sets up another target
        ifelse count other instructors in-radius social-radius = 0 [
          set clear3? true
          set go-back? false
        ]
        [
          set target min-one-of patches with [count other instructors in-radius social-radius = 0 and pycor > (room-margin-y + 5 + table-height * number-of-rows + row-space * (number-of-rows - 1)) and pcolor = black][distance myself]
          face target
        ]
      ]
      [
        ;; Next to if statements are avoiding the grey lab table if necessary
        if [pcolor != black] of patch-ahead 1 and avoiding? = false [ ;; If it detects the grey table it'll change its direction to move around it
          let offset remainder heading 90
          let angle 0 - offset
          while [[pcolor != black] of patch-right-and-ahead angle 1] [
            set angle angle + 90
          ]
          set heading (remainder (heading + angle) 360)
          set avoiding? true
        ]
        if avoiding? [
          if not wall? 90 and not wall? -90 [ face target set avoiding? false]  ;; If there is no grey "wall" at either side it will now try to go to its target again
        ]
        fd 1
      ]
    ]
  )
end

;;;OTHER REPORTING FUNCTIONS;;;-----------------------------------------------------------------------------------------------------------------------------------------------------------

;; Will return true if there is a non-black or red patch at the given angle
to-report wall? [angle]
  if patch-right-and-ahead angle 1 = NOBODY [
    report true
  ]
  report ((black != [pcolor] of patch-right-and-ahead angle 1) and (red != [pcolor] of patch-right-and-ahead angle 1))
end

;; Will return true if there is a student set up in his spot for the demonstration at the given angle
to-report student? [angle]
  if patch-right-and-ahead angle 1 = NOBODY [
    report true
  ]
  let in-front students-on patch-right-and-ahead angle 1
  report 0 != count in-front with [clear4?]
end

;; Sets up the time that has passed in the room
to setup-time
  set hour int ((ticks - 2000) / 24000)
  let remaining remainder (ticks - 2000) 24000
  set minute int (remaining / 400)
  set hour word hour " hours "
  set minute word minute " minutes"
  set time word hour minute
end

;; Checking if person is in contact with some other persons
to check-for-contact
  let students-in-radius [who] of other turtles in-radius 3.5 with [color != [255 0 0 0]]
  let students-in-table NOBODY
  ;; Setting an agentset of the students already in table
  if target-patch != NOBODY and patch-here = target-patch and color != [255 0 0 0] and color != 55 and color != 58 [
    set students-in-table [who] of other students with [int ((chair-num - 1) / chairs-per-table) = int (([chair-num] of myself - 1) / chairs-per-table) and patch-here = target-patch]
  ]
  let i 0
  if students-in-table != NOBODY [
    while [i < length students-in-table][
      ;; Adding the students-in-table to the agentset of students-in-radius if they don't repeat themselves
      if position (item i students-in-table) students-in-radius = false [
        set students-in-radius lput (item i students-in-table) students-in-radius
      ]
      set i i + 1
    ]
  ]
  set i 0
  if length students-in-radius != 0 [
    ;; Updating the ticks-in-contact list
    while [i < length students-in-radius][
      set ticks-in-contact replace-item (item i students-in-radius) ticks-in-contact (item (item i students-in-radius) ticks-in-contact + 1)
      set i i + 1
    ]
    set i 0
    set contacts []
    ;; Updating the contacts list (re-doing it in this case), putting the list of people in contact with in order
    while [i < length ticks-in-contact][
      if item i ticks-in-contact != 0 [
        ifelse length contacts < 1 [
          set contacts lput i contacts
        ]
        [
          let j 0
          while [j < length contacts][ ;; Makes sure to put the student in contact with in the correct position according to order of most contact to least contact
            let current item j contacts
            let next item j contacts
            if j + 1 != length contacts [
              set next item (j + 1) contacts
            ]
            if j + 1 = length contacts or (item i ticks-in-contact >= (item current ticks-in-contact)) or (item i ticks-in-contact <= (item current ticks-in-contact) and item i ticks-in-contact >= (item next ticks-in-contact)) [
              ifelse (item i ticks-in-contact >= (item current ticks-in-contact)) [
                set contacts insert-item 0 contacts i
              ]
              [ set contacts insert-item (j + 1) contacts i ]
              set j length contacts
            ]
            set j j + 1
          ]
        ]
      ]
      set i i + 1
    ]
  ]
end

;; Checks clear for students in front according to the social radius
to check-clear
  set clear? true
  let students-in-front other students in-cone social-radius 60 ;; Students in front in some 60 degree cone
  let boolean false
  let boolean2 false
  let bound1 remainder (heading + 15) 360
  if bound1 < 15 [set boolean true]
  let bound2 heading - 15
  if bound2 < 0 [set bound2 bound2 + 360 set boolean true]
  ;; Setting up the heading bounds above, for students only facing similar directions
  ;; Next line narrows the students in front to those that haven't reached their target or aren't in the exact same patch
  set students-in-front students-in-front with [patch-here != target and chair-number != chair-num and color = blue and patch-here != [patch-here] of myself]
  if friends? [
    ;; If students have friends its friends don't count as those they should social distance from
    ifelse follower? = false [ set students-in-front students-in-front with [self != [following] of myself and not member? self ([blue-link-neighbors] of myself)] ]
    [ set students-in-front students-in-front with [self != [following] of myself and not member? self ([blue-link-neighbors] of one-of ([blue-link-neighbors] of myself))] ]
  ]
  ;if count students-in-front != 0 [set boolean2 true]
  ;; Narrowing the students-in-front down to those with similar heading directions in the next ifelse statement
  ifelse boolean [
    ifelse friends? and ticks > (2000 + lab-time * 400 + 1) [
      set students-in-front students-in-front with [(heading < bound1) or (heading > bound2)]
    ]
    [ set students-in-front students-in-front with [(heading < bound1) or (heading > bound2) or (change-seat? = false and clear2? != [clear2?] of myself and clear1? = [clear1?] of myself and clear3? = [clear3?] of myself and clear4? = [clear4?] of myself) or (change-seat? = false and clear3? != [clear3?] of myself and clear4? = [clear4?] of myself and clear1? = [clear1?] of myself and clear2? = [clear2?] of myself)] ]
  ]
  [
    ifelse friends? and ticks > (2000 + lab-time * 400 + 1) [
      set students-in-front students-in-front with [((heading < bound1) and (heading > bound2))]
    ]
    [ set students-in-front students-in-front with [((heading < bound1) and (heading > bound2)) or (change-seat? = false and clear2? != [clear2?] of myself and clear1? = [clear1?] of myself and clear3? = [clear3?] of myself and clear4? = [clear4?] of myself) or (change-seat? = false and clear3? != [clear3?] of myself and clear4? = [clear4?] of myself and clear1? = [clear1?] of myself and clear2? = [clear2?] of myself)] ]
  ]
  if count students-in-front != 0 [
    set clear? false
  ]

  if friends? and follower? and ticks > (2000 + lab-time * 400 + 1) and [clear2?] of following != clear2? [ ;; Sometimes students will get stuck when going out of room as some are in different movement steps, this prevents that
    set clear? true
  ]
end

;;;COVID CONTAGION FUNCTIONS;;;-----------------------------------------------------------------------------------------------------------------------------------------------------------

;; Initializes infection variables for students newly infected
to become-infected
  ask turtles with [infected? = true] [ask my-red-links [die]]
  set presympt-per one-of (range 4 7)
  set latent-per (presympt-per - 1)
  set sympt-per one-of (range 8 17)
  set color pink
  set label sympt-per
  set label-color magenta - 2
  set infected? true
  set presympt false
  set sympt false
end

;; Function measures the distance of persons to an infected person and gives them a label according to that.
;; The closer they are the higher the label which means a higher probability of being infected
to chance-of-infection
  ask turtles with [sympt = true or presympt = true and color != [255 0 0 0]] [
    create-red-links-with other turtles with [infected? = false and color != [255 0 0 0] ]
    ask red-links [hide-link]
  ]

  ask turtles with [(sympt = true or presympt = true) and color != [255 0 0 0]][
    ask red-link-neighbors [
      if color != [255 0 0 0][
      if min [link-length] of my-red-links <= 2 [
        set label (3)
        set label-color (green)
      ]
      if min [link-length] of my-red-links <= 4 and min [link-length] of my-red-links > 2 [
        set label (2)
        set label-color (green)
      ]
      if min [link-length] of my-red-links > 4 and min [link-length] of my-red-links <= 6 [
        set label (1)
        set label-color (green)
      ]
      if min [link-length] of my-red-links > 6 [
        set label (0)
        set label-color (green)
      ]
    ]
  ]
  ;; If number is 3, students are very close to an infectious person
  ]
  spread-infection
end

;; Function spreads COVID-19 to some of the people that are close to an infected person
to spread-infection
  ask turtles with [presympt = true][ ;; Presymptomatic are given a lower chance of infecting people
    ask red-link-neighbors [
      ifelse mask? = false [
        ;; People without masks get infected easier
        if color != [255 0 0 0] and random 400000 < (3 * label) [
          become-infected
        ]
      ]
      [
        ;; People without masks get that extra protection from the mask
        if random 100 > Mask-efficiency and color != [255 0 0 0] and random 400000 < (3 * label) [
          become-infected
        ]
      ]
    ]
  ]

  ask turtles with [sympt = true][ ;; Symptomatic are given a higher chance of infecting people
    ask red-link-neighbors [
      ifelse mask? = false [
        ;; People without masks get infected easier
        if label = 3 and color != [255 0 0 0] and random 400000 < (2 * (3 * label)) [
          become-infected
        ]
      ]
      [
        ;; People without masks get that extra protection from the mask
        if label = 3 and random 100 > Mask-efficiency and color != [255 0 0 0] and random 400000 < (2 * (3 * label)) [
          become-infected
        ]
      ]
    ]
  ]
end

;; Sets up people that will have masks on
to setup-masked
  ask n-of round ((Percentage-of-masked-people / 100) * (number-of-students + num-of-instructors/TAs)) turtles [
    if breed = instructors [
      set shape "masked-instructor"
      set mask? true
    ]
    if breed = students [
      set shape "masked-student"
      set mask? true
    ]
  ]
end

;; Sets up symptomatic people
to be-symptomatic
  set sympt true
  set presympt false
  set infected? true
  set sympt-per one-of (range 8 17)
end

;; Sets up presymptomatic people
to be-presymptomatic
  set sympt false
  set presympt true
  set infected? true
  set presympt-per one-of (range 4 7)
end
@#$#@#$#@
GRAPHICS-WINDOW
209
13
1072
607
-1
-1
15.0
1
10
1
1
1
0
0
0
1
0
56
0
38
1
1
1
ticks
30.0

BUTTON
16
22
83
56
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
16
216
189
249
number-of-rows
number-of-rows
0
12
3.0
1
1
NIL
HORIZONTAL

SLIDER
16
64
189
97
room-width
room-width
0
100
56.0
1
1
NIL
HORIZONTAL

SLIDER
16
97
189
130
room-height
room-height
0
100
38.0
1
1
NIL
HORIZONTAL

SLIDER
16
139
189
172
room-margin-x
room-margin-x
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
16
294
189
327
table-width
table-width
0
20
6.0
1
1
NIL
HORIZONTAL

SLIDER
16
327
189
360
table-height
table-height
0
15
3.0
1
1
NIL
HORIZONTAL

SLIDER
16
249
189
282
number-of-columns
number-of-columns
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
16
370
189
403
chairs-per-table
chairs-per-table
0
8
5.0
1
1
NIL
HORIZONTAL

SLIDER
16
404
189
437
number-of-students
number-of-students
0
100
60.0
1
1
NIL
HORIZONTAL

BUTTON
90
22
157
56
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
16
173
189
206
room-margin-y
room-margin-y
3
10
4.0
1
1
NIL
HORIZONTAL

MONITOR
927
28
1061
73
Time
time
17
1
11

SLIDER
16
492
189
525
social-radius
social-radius
0
10
0.0
1
1
NIL
HORIZONTAL

SLIDER
16
448
189
481
num-of-instructors/TAs
num-of-instructors/TAs
0
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
16
565
189
598
introduction-time
introduction-time
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
16
598
189
631
demonstration-time
demonstration-time
0
10
2.0
1
1
NIL
HORIZONTAL

SLIDER
16
532
189
565
lab-time
lab-time
0
180
24.0
1
1
NIL
HORIZONTAL

SLIDER
1138
373
1313
406
avg-group-size
avg-group-size
2
5
3.0
1
1
NIL
HORIZONTAL

SLIDER
1139
334
1315
367
percentage-of-groups
percentage-of-groups
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
1138
287
1312
320
initial-outbreak-size
initial-outbreak-size
0
20
2.0
1
1
NIL
HORIZONTAL

PLOT
1082
25
1268
178
Virus Spread
% of students
Time
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot (count students with [infected?]) / (count students) * 100"

MONITOR
940
83
1060
128
Infected Students
count students with [infected?]
0
1
11

SLIDER
1140
477
1314
510
number-of-demonstrations
number-of-demonstrations
0
5
3.0
1
1
NIL
HORIZONTAL

INPUTBOX
1139
416
1317
476
demonstration-lab-tables
038
1
0
String

SLIDER
1142
532
1320
565
number-of-sections
number-of-sections
0
5
3.0
1
1
NIL
HORIZONTAL

CHOOSER
1143
583
1302
628
Sections-split-across
Sections-split-across
"rows" "columns"
0

TEXTBOX
1338
423
1505
568
Write lab # of the labs where you want the demonstrations all together, no spaces. If lab table has double digits write a period before it. Example: for demonstrations in lab table 0, 1, 5, 11 you would write 015.11. Make sure the number of demonstrations is also adjusted to what's necessary
11
0.0
1

SLIDER
1144
642
1326
675
fraction-students-per-dem
fraction-students-per-dem
0
5
3.0
1
1
NIL
HORIZONTAL

TEXTBOX
1345
636
1512
709
Fraction of students per demonstration at the same time. Example: 4 will have 1/4 of the students at one demonstration at once
11
0.0
1

SLIDER
16
650
190
683
avg-answering-time
avg-answering-time
0
15
3.0
1
1
NIL
HORIZONTAL

SLIDER
16
684
190
717
avg-freq-question
avg-freq-question
0
100
10.0
1
1
NIL
HORIZONTAL

TEXTBOX
22
726
189
813
Average frequency with which a question is asked per lab group. Example: a value of 5 will have lab groups ask a question an average of once every 5 minutes.
11
0.0
1

SLIDER
1145
688
1318
721
presymptomatic
presymptomatic
0
100
55.0
1
1
%
HORIZONTAL

SLIDER
1145
733
1318
766
mask-efficiency
mask-efficiency
0
100
50.0
1
1
%
HORIZONTAL

SLIDER
1147
775
1369
808
percentage-of-masked-people
percentage-of-masked-people
0
100
50.0
1
1
%
HORIZONTAL

@#$#@#$#@
## WHAT IS IT?

This model is a physical representation of students and instructors moving around a lab room. The model allows for different configurations of the lab room. The size of the room, number of tables, number of chairs, number of experiment sections, number of experiment demonstrations, and lab times are among many variable inputs to represent different lab room configurations.

The model project simulates the movement of students and instructors in typical lab behavior. Accounting for group movement, demonstration movement and questions movement makes for an accurate representation of a lab period. Having COVID-19 contagion behavior added to the physical movement of students and instructor makes for a meaningful model where we can predict the spread of COVID-19 during a lab period. This helps us reach the purpose of this model: to determine which lab configurations will be safest and predict how COVID-19 could spread on a hybrid return to classes. 

## HOW IT WORKS

At the setup procedure students are each assigned a chair number and they might be in a group of friends depending on the percentage of students in groups. If they are in a group, the group will have a size around the average, and they will all have seats assigned in the same lab table. Groups of friends will be linked to each other with a blue link and move together. Students will then enter the room at a random time assigned within 5 minutes before the lab time begins. Once seated they'll move to demonstration lab tables and switch from one experiment section to another if necessary. They'll also ask questions at random times, with no more than one student at the same table asking a question at the a time. Once their question is answered they will not have a question for at least a small amount of time. As the lab time finishes students will exit the room if all there questions have been answered. Their exit times are somewhat random as when one person at a table leaves, the rest of the table will leave soon after.

As for the instructors/TAs, one is set up as the "main" instructor which is visible with a slightly lighter green to all the other instructors. The main instructor will give the introduction at the front and center of the room while all the other instructors/TAs are simply standing somewhere at the front of the room. The main instructor will also move from one demonstration to another if the whole class of students is simply moving from one demosntration to another rather than in groups. Otherwise it'll simply stay at one of the demonstration, generally the one in the front of the room if there is a demonstration to do there. As for the non-main instructors/TAs they will simply move to the edges to avoid students whenever they are not giving a demonstration. However, some non-main instructors/TAs will be giving a demonstration if there is multiple groups of students looking at a demonstration at the same time. In this case the necessary instructors will simply move to one of the demonstration labs and stay there until all demonstrations are done. Intructors will also go and answer questions when necessary and move from question to question, if they are not answering a question they'll go to the front of the room. The time they take answering a question is random.

### MOVEMENT STRUCTURE

The general movement structure for the movement of both students and instructors/TAs is one where they depend mainly on the number of ticks and what position they're currently at. The number of ticks first determines what a person should be doing, whether it's time to move to a demonstration, to change seat to a different experiment section, or to leave the lab room. Once the ticks indicate what a person should be doing they do so by calling the functions necessary for such action. The structure of such functions generally have movement steps. Each step labeled by variables such as clear1? or clear2? moves you to a certain target patch, and once the student or instructor/TA reaches that target the function sets up an appropriate target to move to next. Some of these functions get a little bit more complex as there is other factors to consider such as group movement, social distancing, the persons starting location among others.

#### DEMONSTRATIONS

- Demonstrations happen at the beginning of the lab period, after the introduction. At such demonstrations students will make there way to the appropriate demonstration lab table were they'll be standing around, watching the instructor perform some part of the experiment.

- If the fraction of students per demonstration is one that means they'll all go to the demonstration at the same time and will move from one demonstration to the other given that theree are multiple to show. Otherwise students will be seperated into groups for the demonstration, each group having a certain amount of tables. Groups will alternate from demonstration to demonstration, and if there is more groups of students than number of demonstrations some groups will remain seated while demonstrations are taking place.

#### EXPERIMENT SECTIONS

- Experiment sections can be either split across rows or columns, and are identified by having one patch in the table a specific color. Splitting them across rows will give you one section in a row of lab tables, and if the number of tables in the section don't fit in one row it'll fill the section in "snake" form on a different row. If a section doesn't complete a row, the next section will begin in that same row. Same strategy is true for splitting the section across columns.

- If the number of tables per section is not even then the first sections get one more table until necessary. For example, if there is 12 tables and 5 sections the first two sections get 3 tables and the last 3 sections get 2 tables.

- Students will move from one experiment section to another at the same time, giving each experiment the same amount of time for students to work on it. Students will change seats by jumping the appropriate amount of tables to be in a different section. They're new seat will be in the same position as in the last lab table they were in.

#### GROUPS

- Groups of student friends are set up at the beginning, with a certain percentage of student being part of a group with x number of students in it. Groups are adjusted so that if there is 7 students with a group of 5 students, 2 of those students get downgraded to a 4 person group and so on. Occasianally a student will go from having a pair to being a lone student because of this.

- Each group will have a main student and the rest will be followers of such main student. The main student will have a blue link to all the followers. Followers will position themselves either beside or behind the main student and "follow" such student to their lab table and out of the room after the lab period is over.

### COVID CONTAGION

COVID-19 contagion effects can be looked at in two ways through this model. The first one is to look at the list of contacts which is in order of the person the analyzed student/instructor was most in contact with to the person it was in the least contact with. The turtle-owned variable contact-tracing can be looked at to see for how many seconds a person was in contact with all other persons. As for global variables avg-contact and avg-contact-seconds, those can indicate the average number of contacts per person during the whole lab period and the average seconds in contact per person.

The other way COVID-19 contagion can be looked is by analyzing the actual contagion parameters and virus spread. People in pink are those that are infected with the virus and they will slowly infect it to other people. Those who are closest to the infected person have a higher chance of being infected. Infected people will be either symptomatic or presymptomatic, with those that are presymptomatic having a lower chance of infecting other people. A graph in the interface monitors the virus spread throughout the lab room.

## HOW TO USE IT

Click the "setup" button to setup the whole lab room and student variables according to the input parameters. Click the "go" button to have the simulation run, you'll see student and instructor movemnet across the room until the lab period is over. You'll also be able to see how COVID-19 spreads within the people in the room and graphs showing you such contagion. Input parameters can be changed in the Lab-room-parameter.txt file.

### PARAMETERS

Some of the variable parameters for the model. Parameters not explained here are pretty self explanatory.

- Percentage of groups: The percentage of students thar are part of a friend group

- Average group size: The average friend group size, sizes will usually vary only a few students from the average

- Social radius: The social radius (in number of patches) a student should try to keep from another student while moving around the room.

- Demonstration lab tables numbers: The lab numbers of the labs where you want the demonstrations to happen. These should be written all together, no spaces, and if the desired lab table has a double digit number write a period before it. Example: for demonstrations in lab table 0, 1, 5, 11 you would write 015.11 in the .txt file. Make sure the number of demonstrations matches the list of lab tables numbers.

- Fraction of students per demonstration at the same time: Input the whole number which will be represented as a fraction. Inputing 2 means 1/2 of the class can be in one demonstration at the same time. Essentially the number inputed is the number of groups that will be going from demonstration to demonstration.

- Number of Sections: The number of experiment sections during the lab period. Will be visible with different patch colors in each lab table.

- Sections split across the rows or columns?: The experiment sections can either be divided across rows or columns. Write "rows" or "columns" with the quotation marks for the input file to work.

## THINGS TO NOTICE

While running the model look at all the different movement and sections of the lab period. How does the spread of COVID-19 change during different movements. Is there a higher risk during demonstrations or when students come in or out of class? How about when students are simply seated and asking questions, or when students move from one experiment section another? As you change the lab tables for demonstrations, is there a difference in having a demonstration in the front of the room rather than in other lab tables?

Notice how for a significant period of time instructors/TAs are the only ones moving around, so how does the spread of the virus change when an instructor gets infected vs when they do not? Aditionally, students may or may not use masks, notice how students are much more vulnerable to getting infected when they are not wearing a mask. How does this change the total spread of the virus in the lab room?
 

## THINGS TO TRY

Split the sections even across either rows or columns. That being having the same number of sections as lets say rows and having it set to split across rows. This results in the students moving less across the room and therefore likely spreading the virus slower. Compare this to when the sections are not evenly split across rows or columns.

Try running behavior space to analyze COVID-19 contagion with different number of seats per lab table. Do the same with different number of tables which will change the total number of seats. Also run behavior space with different number of students as labs maybe limited to an ideal number of students.

Try varying the the lab and demonstration times and see how the results vary. Repeat it with different number of section or number of demonstrations. Finish experimenting with behavior space by changing the fraction of students per demonstration. Does the smaller groups contain COVID-19 contagion better or does the extra movement of groups increase the risk of spread?

## EXTENDING THE MODEL

This Lab Room model is already very complex, however there's still a few things that could be added that might make the model more accurate. For starters students are never programs to go to the bathroom in the model, adding that would make this model a little bit more realistic, especially in long lab periods. Instructors also usually walk around the room when they have nothing else to do, adding that could prove to be more accurate.

We are also only working with one lab period in this lab room model, adding a schedule for students to follow could extend our results. You could even add multiple groups of students representing different lab blocks. In this case having some students potentially returning to class with the virus (aquired from someone outside of class) would be something to consider.

## NETLOGO FEATURES

If you look closely at this model you'll see the groups of friends connected with blue links and flashes of red links connected from infected students for contagion measuring purposes. This isn't just a visual aspect but rather different link breeds for different link purposes. This netlogo feature allowing for different link breeds helps perform seperate functions for the seperate breeds. Using blue-link-neighbors or red-link-neighbors allows for access of only relevant agents for certain operations.

The model also utilized the in-cone netlogo function. Using this for checking if a student is clear for movement is crucial as it only reports the agents in a 60 degree view rather than the full radius of the student. If we did not resort to the in-cone netlogo function students would get stuck way to often at times where they should be moving.

## RELATED MODELS

The other summer research COVID-19 models

## CREDITS AND REFERENCES

COVID-19 contagion research links

## HOW TO CITE

If you mention this model or the NetLogo software in a publication, we ask that you include the citations below.

For the model itself:

* Villarreal, J. (2020).  NetLogo COVID Lab Room model.  http://ccl.northwestern.edu/netlogo/models/COVIDLabRoom.  Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

Please cite the NetLogo software as:

* Wilensky, U. (1999). NetLogo. http://ccl.northwestern.edu/netlogo/. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.

## COPYRIGHT AND LICENSE

Copyright 2007 Uri Wilensky.

![CC BY-NC-SA 3.0](http://ccl.northwestern.edu/images/creativecommons/byncsa.png)

This work is licensed under the Creative Commons Attribution-NonCommercial-ShareAlike 3.0 License.  To view a copy of this license, visit https://creativecommons.org/licenses/by-nc-sa/3.0/ or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.

Commercial licenses are also available. To inquire about commercial licenses, please contact Uri Wilensky at uri@northwestern.edu.

<!-- 2007 Cite: Bakshy, E. -->
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

instructor
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Polygon -1 true false 135 90 165 90 150 105 165 120 165 150 150 165 135 150 135 120 150 105 135 90

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

masked-instructor
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Rectangle -1 true false 120 45 180 75
Polygon -1 true false 135 90 165 90 150 105 165 120 165 150 150 165 135 150 135 120 150 105 135 90

masked-student
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105
Rectangle -1 true false 120 45 180 75

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.1.1
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="4 columns, 2 rows" repetitions="15" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="47000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
  </experiment>
  <experiment name="2 columns, 4 rows" repetitions="15" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="47000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
  </experiment>
  <experiment name="3 columns, 3 rows" repetitions="15" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
  </experiment>
  <experiment name="3 columns, 4 rows" repetitions="15" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
  </experiment>
  <experiment name="4 columns, 3 rows" repetitions="15" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
  </experiment>
  <experiment name="4 columns, 4 rows" repetitions="15" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
  </experiment>
  <experiment name="Increasing num-of-students" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <steppedValueSet variable="number-of-students" first="25" step="5" last="60"/>
  </experiment>
  <experiment name="Increasing num-of-sections-rows" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <steppedValueSet variable="number-of-sections" first="1" step="1" last="5"/>
  </experiment>
  <experiment name="Demonstration locations" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <enumeratedValueSet variable="demonstration-lab-tables">
      <value value="&quot;038&quot;"/>
      <value value="&quot;308&quot;"/>
      <value value="&quot;380&quot;"/>
      <value value="&quot;357&quot;"/>
      <value value="&quot;369&quot;"/>
      <value value="&quot;147&quot;"/>
      <value value="&quot;258&quot;"/>
      <value value="&quot;30.12&quot;"/>
      <value value="&quot;508&quot;"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Number of demonstrations" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <steppedValueSet variable="number-of-demonstrations" first="1" step="1" last="5"/>
  </experiment>
  <experiment name="Time of demonstrations" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <steppedValueSet variable="demonstration-time" first="1" step="1" last="5"/>
  </experiment>
  <experiment name="Increasing num-of-sections-columns" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <steppedValueSet variable="number-of-sections" first="1" step="1" last="5"/>
  </experiment>
  <experiment name="Increasing lab times" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="80000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <steppedValueSet variable="lab-time" first="45" step="15" last="180"/>
  </experiment>
  <experiment name="Increasing freq questions" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <steppedValueSet variable="avg-freq-question" first="4" step="2" last="20"/>
  </experiment>
  <experiment name="Increasing group size" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <steppedValueSet variable="avg-group-size" first="2" step="1" last="5"/>
  </experiment>
  <experiment name="Fraction students per demonstrations" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <steppedValueSet variable="fraction-students-per-dem" first="1" step="1" last="5"/>
  </experiment>
  <experiment name="Social radius" repetitions="10" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="43000"/>
    <metric>[contact-tracing] of turtles</metric>
    <metric>[ticks-in-contact-order] of turtles</metric>
    <metric>[contacts] of turtles</metric>
    <metric>[contacts-shorted] of turtles</metric>
    <metric>[length contacts-shorted] of turtles</metric>
    <metric>[avg-ticks] of turtles</metric>
    <metric>avg-contact</metric>
    <metric>avg-contact-seconds</metric>
    <steppedValueSet variable="social-radius" first="0" step="2" last="10"/>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
