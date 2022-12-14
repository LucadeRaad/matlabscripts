do_bandpass = true;

%[unordered_eeg, names_unordered_eeg] = parse_eeg('Data_RandomClench', '*_raw.csv', do_bandpass);

[ordered_eeg, names_ordered_eeg, model] = parse_eeg('Data_Clench_RAW', '*_raw.csv', do_bandpass);

bandpass_model = model(1);

bandpass_model = bandpass_model{1};