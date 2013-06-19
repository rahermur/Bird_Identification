function [cepstra, aspectrum, pspectrum] = extract_MFCC(syllables,sr)



		window= 512 ;
		val_fbtype='mel';
		val_broaden=0;
		val_maxfreq=sr/2;
		val_minfreq=0;
		val_wintime=window/sr;
		val_hoptime=val_wintime/3;
		val_numcep= 16 ;
		val_usecmp= 0 ;	
		val_dcttype= 3 ;
		val_nbands= 32 ;
		val_dither= 0 ;
		val_lifterexp= 0 ;
		val_sumpower= 1 ;
		val_preemph= 0 ;
		val_modelorder=0;
		val_bwidth= 1 ;

		val_useenergy= 1 ; % set the first coefficient to log(energy) ; if you prefer to set it to the first MFCC coeff, rerun with val_useenergy=0 

		[cepstra,aspectrum,pspectrum] = melfcc(syllables, sr, ...
            'wintime',val_wintime,'hoptime',val_hoptime,'numcep',val_numcep, ...
            'lifterexp',val_lifterexp,'sumpower',val_sumpower, ...
            'preemph',val_preemph,'dither',val_dither,'minfreq',val_minfreq, ...
            'maxfreq',val_maxfreq,'nbands',val_nbands,'bwidth', ...
            val_bwidth,'dcttype',val_dcttype,'fbtype',val_fbtype, ...
            'usecmp',val_usecmp,'modelorder',val_modelorder, ...
            'broaden',val_broaden,'useenergy',val_useenergy);


end